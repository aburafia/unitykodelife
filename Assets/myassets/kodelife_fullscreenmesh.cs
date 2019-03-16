using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent (typeof(MeshRenderer))]
[RequireComponent (typeof(MeshFilter))]
public class kodelife_fullscreenmesh : MonoBehaviour {

    void Start () {
		var mesh = new Mesh ();
    	var vecs = new Vector3[] {
            new Vector3 (-1, -1, 0f),
            new Vector3 (-1f, 1f, 0f),
            new Vector3 (1f, 1f, 0f),
            new Vector3 (1f, -1f, 0f)
        };
		mesh.vertices = vecs;
        mesh.triangles = new int[] {
            0, 1, 2, 0, 2, 3
        };
        var filter = GetComponent<MeshFilter> ();
        filter.sharedMesh = mesh;

	}

 
}
