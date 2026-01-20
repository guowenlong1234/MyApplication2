import audio from '@ohos.multimedia.audio';
import http from '@ohos.net.http';
import util from '@ohos.util';
import { BusinessError } from '@ohos.base';

export class VoiceService {
  private audioCapturer: any = null; // 用 any 绕过检查
  private isRecording: boolean = false;
  private pcmData: Array<number> = [];

  // 🔴 必须替换为你的百度云 API Key 和 Secret Key 🔴
  private readonly API_KEY = 'sJclhyvKi9oH7bdmCVTCyAvV';
  private readonly SECRET_KEY = 'UaWRFyRfh48P7SUWZT23JQ4odTxEk6jR';

  // 回调函数：把实时音量(0-100)传给 UI
  private onVolumeChange: (volume: number) => void = () => {};

  // 1. 开始录音 (接收一个回调函数)
  async startRecording(callback?: (vol: number) => void) {
    if (this.isRecording) return;
    this.pcmData = [];
    if (callback) this.onVolumeChange = callback;

    let audioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000,
      channels: audio.AudioChannel.CHANNEL_1,
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
    };

    let audioCapturerInfo = {
      source: audio.SourceType.SOURCE_TYPE_MIC,
      capturerFlags: 0
    };

    let audioCapturerOptions = {
      streamInfo: audioStreamInfo,
      capturerInfo: audioCapturerInfo
    };

    try {
      this.audioCapturer = await audio.createAudioCapturer(audioCapturerOptions);

      // 监听音频数据读取
      (this.audioCapturer as any).on('read', (buffer: any) => {
        let tempArray = new Uint8Array(buffer);


        // --- 核心：计算音量 (RMS 算法简化版) ---
        let sum = 0;
        for (let i = 0; i < tempArray.length; i += 2) {
          let val = (tempArray[i+1] << 8) | tempArray[i];
          if (val > 32767) val -= 65536;
          sum += Math.abs(val);
          this.pcmData.push(tempArray[i]);
          this.pcmData.push(tempArray[i+1]);
        }

        let avg = sum / (tempArray.length / 2);

        // 🔴【插入测试日志 2】看看计算出来的平均音量是多少
        // 如果一直是 0，说明录到的是静音。如果很小(比如 1-5)，说明麦克风声音太小
        console.info(`[VoiceTest] 当前平均振幅: ${avg}`);

        let volume = Math.min(100, avg / 50);
        this.onVolumeChange(volume);
      });

      await this.audioCapturer.start();
      this.isRecording = true;
      console.info('[Voice] 开始录音...');
    } catch (err) {
      console.error('[Voice] 录音启动失败:', JSON.stringify(err));
    }
  }

  // 2. 停止录音并识别
  async stopAndRecognize(): Promise<string> {
    if (!this.audioCapturer || !this.isRecording) return "未在录音";

    try {
      await this.audioCapturer.stop();
      await this.audioCapturer.release();
      this.isRecording = false;
      this.onVolumeChange(0); // 归零

      // 转换为 Base64
      let uint8Array = new Uint8Array(this.pcmData);
      let base64Helper = new util.Base64Helper();
      let base64Audio = base64Helper.encodeToStringSync(uint8Array);

      let token = await this.getAccessToken();
      return await this.sendToBaidu(base64Audio, token);

    } catch (err) {
      console.error('[Voice] 流程异常:', JSON.stringify(err));
      return "识别出错"; // 返回这个，UI层会捕获
    }
  }

  // 3. 获取 Token
  async getAccessToken(): Promise<string> {
    const url = `https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=${this.API_KEY}&client_secret=${this.SECRET_KEY}`;
    let req = http.createHttp();
    let result = await req.request(url, { method: http.RequestMethod.POST });

    if (result.responseCode !== 200) return "";
    let data = JSON.parse(result.result as string);
    return data.access_token;
  }

  // 4. 发送给百度
  async sendToBaidu(base64Data: string, token: string): Promise<string> {
    if (!token) return "网络错误";

    let url = `https://vop.baidu.com/server_api`;
    let body = {
      format: "pcm",
      rate: 16000,
      channel: 1,
      cuid: "rvbook_demo",
      token: token,
      speech: base64Data,
      len: this.pcmData.length
    };

    let req = http.createHttp();
    let result = await req.request(url, {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' },
      extraData: JSON.stringify(body)
    });

    let resData = JSON.parse(result.result as string);
    if (resData.err_no === 0) {
      return resData.result[0];
    } else {
      console.error('[Voice] API Error:', resData.err_msg);
      return "无法识别";
    }
  }
}