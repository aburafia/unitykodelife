using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class kodelife_camera : MonoBehaviour
{

	public RenderTexture[] _rt;
	public kodelife_io kio;
	public Camera cam;
 
    // Start is called before the first frame update
	void Start()
    {
		cam = GetComponent<Camera>();
		kio = GetComponent<kodelife_io>();
		_rt = new RenderTexture[8];

        for (int i=0; i< _rt.Length; i++)
        {
            _rt[i] = new RenderTexture(2048, 2048, 32);
        }

        cam.SetTargetBuffers(new RenderBuffer[8] { _rt[0].colorBuffer, _rt[1].colorBuffer, _rt[2].colorBuffer, _rt[3].colorBuffer
            , _rt[4].colorBuffer, _rt[5].colorBuffer , _rt[6].colorBuffer, _rt[7].colorBuffer}
            , _rt[0].depthBuffer);

		kio = GetComponent<kodelife_io>();

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
