using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent (typeof(AudioSource))]
public class kodelife_io : MonoBehaviour {

	// Use this for initialization
    AudioSource audioSource;
	public float マイクの反応率 = 100f;
	public float ボリューム;
	public float 経過時間;
	public RenderTexture 前のcolorbuffer;
	public RenderTexture 前のdepthbuffer;
	Camera camera;
	//public Material postmat;

	void Start () {
		前のcolorbuffer = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);
		camera  = GetComponent<Camera>();
		//camera.targetTexture = 前のcolorbuffer;


		////デフォルトのmatを取得
		//#if UNITY_EDITOR
		//postmat = UnityEditor.AssetDatabase.GetBuiltinExtraResource<Material>("Default-Diffuse.mat");
		//#else
		//postmat = Resources.GetBuiltinResource<Material>("Default-Diffuse.mat");
		//#endif

		audioSource = GetComponent<AudioSource>();
		micStart();
	}
	
	// Update is called once per frame
	void Update () {
		経過時間 = Time.realtimeSinceStartup;
		ボリューム  = getMicVolume();
	}


	void OnRenderImage(RenderTexture source, RenderTexture destination){ 
		Graphics.Blit(source, 前のcolorbuffer);
		Graphics.Blit(source, destination);
	}

	void micStart () {

        string[] devs = Microphone.devices;
        foreach (string s in devs)
        {
            print(s);
        }

        audioSource.clip = Microphone.Start(null, true, 1, 44100);
        //audioSource.clip = Microphone.Start(mic, true, 10, 44100);

        while (!(Microphone.GetPosition("") > 0)) { }             // マイクが取れるまで待つ。空文字でデフォルトのマイクを探してくれる
    }

	public float getMicVolume()
    {
        int _sampleWindow = 128;
        float levelMax = 0;
        float[] waveData = new float[_sampleWindow];

        int micPosition = Microphone.GetPosition(null) - (_sampleWindow + 1); // null means the first microphone
        if (micPosition < 0) return 0;
        audioSource.clip.GetData(waveData, micPosition);
        // Getting a peak on the last 128 samples
        for (int i = 0; i < _sampleWindow; i++)
        {
            float wavePeak = waveData[i] * waveData[i];
            if (levelMax < wavePeak)
            {
                levelMax = wavePeak;
            }
        }

        return levelMax * マイクの反応率;

    }

	//public void makePrevframeTexture(){
	//	Camera cam = GetComponent<Camera>();
	//	前のcolorbuffer = new RenderTexture(2048, 2048, 32);
	//	前のdepthbuffer = new RenderTexture(2048, 2048, 32);

	//	cam.SetTargetBuffers(前のcolorbuffer, 前のdepthbuffer);

	//	cam.SetTargetBuffers(new RenderBuffer[8] { _rt[0].colorBuffer, _rt[1].colorBuffer, _rt[2].colorBuffer, _rt[3].colorBuffer
	//		, _rt[4].colorBuffer, _rt[5].colorBuffer , _rt[6].colorBuffer, _rt[7].colorBuffer}
	//		, _rt[0].depthBuffer);

	//	kio = GetComponent<kodelife_io>();

	//}

	//public void setPrevframeTexture(){
	//	前のレンダリング結果
	//}


}
