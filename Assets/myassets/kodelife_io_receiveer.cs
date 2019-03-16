using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class kodelife_io_receiveer : MonoBehaviour {

	// Use this for initialization
	Material material;
	kodelife_io _io;

	void Start () {
		material = GetComponent<Renderer>().material;
		_io = GameObject.Find("Main Camera").GetComponent<kodelife_io>();
	}
	
	// Update is called once per frame
    private void Update()
    {

		material.SetFloat("_pasttime", _io.経過時間);
		material.SetFloat("_volume", Mathf.Clamp(_io.ボリューム,0.0f,1.0f));
		material.SetTexture("_prevframe", _io.前のcolorbuffer);
    }

}
