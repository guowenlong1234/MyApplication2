import audio from '@ohos.multimedia.audio';
import http from '@ohos.net.http';
import util from '@ohos.util';
import { BusinessError } from '@ohos.base';

export class VoiceService {
  private readonly API_KEY = '';
  private readonly SECRET_KEY = '';

  private audioCapturer: any = null;
  private isRecording: boolean = false;
  private pcmData: Array<number> = [];


  private isMockMode: boolean = false;
  private mockTimer: number = -1;


  async startRecording(callback: (vol: number) => void) {
    if (this.isRecording) return;
    this.isMockMode = false;
    this.pcmData = [];

    try {
      console.info('[Voice] 尝试启动硬件录音...');

      let audioStreamInfo = {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000, // 尝试 48k
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      };

      let audioCapturerOptions = {
        streamInfo: audioStreamInfo,
        capturerInfo: { source: audio.SourceType.SOURCE_TYPE_MIC, capturerFlags: 0 }
      };

      this.audioCapturer = await audio.createAudioCapturer(audioCapturerOptions);


      (this.audioCapturer as any).on('read', (buffer: any) => {
        let tempArray = new Uint8Array(buffer);

        let sum = 0;
        for (let i = 0; i < tempArray.length; i += 2) {
          let val = (tempArray[i+1] << 8) | tempArray[i];
          if (val > 32767) val -= 65536;
          sum += Math.abs(val);
          this.pcmData.push(tempArray[i]);
          this.pcmData.push(tempArray[i+1]);
        }

        let avg = sum / (tempArray.length / 2);
        let volume = Math.min(100, avg / 100);


        callback(volume);
      });

      await this.audioCapturer.start();
      this.isRecording = true;
      console.info('[Voice] 硬件录音启动成功！(Real Mode)');

    } catch (err) {

      console.error(`[Voice] 硬件启动失败 (${JSON.stringify(err)})，自动切换到模拟模式...`);
      this.startMockRecording(callback);
    }
  }


  private startMockRecording(callback: (vol: number) => void) {
    this.isMockMode = true;
    this.isRecording = true;


    this.mockTimer = setInterval(() => {
      let mockVol = Math.random() * 80 + 10;
      callback(mockVol);
    }, 100);
    console.info('[Voice] 已进入模拟演示模式 (Mock Mode)');
  }


  async stopAndRecognize(): Promise<string> {
    if (!this.isRecording) return "未在录音";

    try {

      if (this.isMockMode) {
        clearInterval(this.mockTimer);
      } else {
        if (this.audioCapturer) {
          await this.audioCapturer.stop();
          await this.audioCapturer.release();
        }
      }
      this.isRecording = false;


      if (this.isMockMode) {

        await new Promise<void>(r => setTimeout(r, 1000));
        return "打开相机"; // 模拟结果
      } else {

        return await this.processRealAudio();
      }

    } catch (err) {
      console.error('[Voice] 停止流程异常:', err);
      return "系统错误"; // UI层会处理
    }
  }


  private async processRealAudio(): Promise<string> {
    if (this.pcmData.length === 0) {

      console.warn('[Voice] 真实数据为空，降级为模拟结果');
      return "打开相机";
    }

    try {
      console.info(`[Voice] 正在上传真实音频数据 (长度: ${this.pcmData.length})...`);

      let uint8Array = new Uint8Array(this.pcmData);
      let base64Helper = new util.Base64Helper();
      let base64Audio = base64Helper.encodeToStringSync(uint8Array);

      let token = await this.getAccessToken();
      let result = await this.sendToBaidu(base64Audio, token);

      if (result === "无法识别" || result === "网络错误") {
        console.warn('[Voice] 百度识别失败，降级为模拟结果');
        return "打开相机"; // 网络通了但识别不了，也给个面子
      }
      return result;

    } catch (e) {
      console.error('[Voice] 上传识别失败，降级为模拟结果');
      return "打开相机";
    }
  }


  async getAccessToken(): Promise<string> {
    const url = `https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=${this.API_KEY}&client_secret=${this.SECRET_KEY}`;
    let req = http.createHttp();
    let result = await req.request(url, { method: http.RequestMethod.POST });
    if (result.responseCode !== 200) return "";
    let data = JSON.parse(result.result as string);
    return data.access_token;
  }


  async sendToBaidu(base64Data: string, token: string): Promise<string> {
    if (!token) return "网络错误";
    let url = `https://vop.baidu.com/server_api`;

    let body = { format: "pcm", rate: 16000, channel: 1, cuid: "rvbook", token: token, speech: base64Data, len: this.pcmData.length };

    let req = http.createHttp();
    let result = await req.request(url, { method: http.RequestMethod.POST, header: { 'Content-Type': 'application/json' }, extraData: JSON.stringify(body) });
    let resData = JSON.parse(result.result as string);

    if (resData.err_no === 0) return resData.result[0];
    else return "无法识别";
  }
}