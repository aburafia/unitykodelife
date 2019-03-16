using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class CameraController : MonoBehaviour
{

    public Vector3 FirstPosition;
    public Quaternion FirstRotation;

    public GameObject MenuCanvas;
    public int MenuBool = 0;

    // Switch 0 or 1
    public int isAutoPhotographingMode = 1;

    // ManualPhotographingMode
    public int walk_speed;
    public int run_speed;
    int speed;

    // AutoPhotographingMode
    public GameObject Target_Root_GameObject;
    public List<GameObject> Annotation_gameObjects;

    public List<GameObject> Annotation_gameObjects_truth;

    private Vector3 targetPosition;

    public int PhotographingTime;
    public int PhotographingInterval;
    public float CameraTrackRadius;
    public int CameraRotationAngle;
    public float CameraAltitudeUpperLimit;
    public float CameraAltitudeLowerLimit;
    public float CameraRiseAndFallWidth;

    float timer;
    bool isOnce = true;

    public Material pink_material;

    public List<List<Material>> beforeMaterials = new List<List<Material>>();
    // List<Material> Target_beforeMaterials = new List<Material>();

    // Start is called before the first frame update
    void Start()
    {
        FirstPosition = transform.position;
        FirstRotation = transform.rotation;
        speed = walk_speed;

        // Annotation_gameObjectsの要素のうち、Rendererコンポーネントを持たない要素を除いたAnnotation_gameObjects_truthを作る
        for (int i = 0; i < Annotation_gameObjects.Count; ++i)
        {
            if(Annotation_gameObjects[i].GetComponent<Renderer>() != null)
            {
                Annotation_gameObjects_truth.Add(Annotation_gameObjects[i]);
            }
        }

        SaveBeforeMaterials();
        // Target_SaveBeforeMaterials();
    }

    // Update is called once per frame
    void Update()
    {
        // 経過時間timer
        timer += Time.deltaTime;

        if (isAutoPhotographingMode == 0) {
            ////////// 手動撮影モード //////////
            float angleDir = transform.eulerAngles.y * (Mathf.PI / 180.0f);
            Vector3 dir1 = new Vector3(Mathf.Sin(angleDir), 0, Mathf.Cos(angleDir));
            Vector3 dir2 = new Vector3(-Mathf.Cos(angleDir), 0, Mathf.Sin(angleDir));

            if (Input.GetKeyDown(KeyCode.Return))
            {
                // Target_PinkOn();
                PinkOn();
            }
            if (Input.GetKeyDown(KeyCode.Backspace))
            {
                // Target_PinkOff();
                PinkOff();
            }

            // 手動カメラ操作
            if (Input.GetKey(KeyCode.LeftShift))
            {
                speed = run_speed;
            }
            else
            {
                speed = walk_speed;
            }
            if (Input.GetKey(KeyCode.W))
            {
                transform.position += dir1 * speed * Time.deltaTime;
            }
            if (Input.GetKey(KeyCode.A))
            {
                transform.position += dir2 * speed * Time.deltaTime;
            }
            if (Input.GetKey(KeyCode.S))
            {
                transform.position += -dir1 * speed * Time.deltaTime;
            }
            if (Input.GetKey(KeyCode.D))
            {
                transform.position += -dir2 * speed * Time.deltaTime;
            }
            if (Input.GetKey(KeyCode.PageUp))
            {
                transform.position += new Vector3(0, speed, 0) * Time.deltaTime;
            }
            if (Input.GetKey(KeyCode.PageDown))
            {
                transform.position += new Vector3(0, -speed, 0) * Time.deltaTime;
            }

            if (Input.GetKeyDown(KeyCode.M))
            {
                if (MenuBool == 0)
                {
                    // メニューを開く処理

                    // GetComponent<HideMouse>().enabled = false;
                    //GetComponent<UniStormMouseLook>().enabled = false;

                    MenuCanvas.SetActive(true);
                    Time.timeScale = 0;
                }
                else
                {
                    // メニューを閉じる処理

                    // GetComponent<HideMouse>().enabled = true;
                    //GetComponent<UniStormMouseLook>().enabled = true;

                    MenuCanvas.SetActive(false);
                    Time.timeScale = 1;
                }

                // フラグ切替
                MenuBool = 1 - MenuBool;
            }

        }
        else
        {
            ////////// 自動撮影モード //////////

            // 一回きりの処理
            if (isOnce)
            {
                //GetComponent<UniStormMouseLook>().enabled = false;
                transform.position = new Vector3(Target_Root_GameObject.transform.position.x + CameraTrackRadius, CameraAltitudeLowerLimit, Target_Root_GameObject.transform.position.z);
                isOnce = false;
            }

            try
            {
                Vector3 center = Target_Root_GameObject.GetComponent<Renderer>().bounds.center;
                transform.RotateAround(center, transform.TransformDirection(Vector3.up), CameraRotationAngle * Time.deltaTime);
                transform.LookAt(center);
            }
            catch
            {
                Vector3 center = Target_Root_GameObject.transform.position;
                transform.RotateAround(center, transform.TransformDirection(Vector3.up), CameraRotationAngle * Time.deltaTime);
                transform.LookAt(center);
            }

            // カメラのY座標を取得
            float now_position_y = transform.position.y;

            if (now_position_y + CameraRiseAndFallWidth * Time.deltaTime > CameraAltitudeUpperLimit)
            {
                CameraRiseAndFallWidth *= -1;
            }
            else if (now_position_y + CameraRiseAndFallWidth * Time.deltaTime < CameraAltitudeLowerLimit)
            {
                CameraRiseAndFallWidth *= -1;
            }

            now_position_y += CameraRiseAndFallWidth * Time.deltaTime;

            if (!(now_position_y < CameraAltitudeLowerLimit || now_position_y > CameraAltitudeUpperLimit))
            {
                transform.position = new Vector3(transform.position.x, now_position_y, transform.position.z);
            }
        }
    }

    /*
    void Target_PinkOn()
    {
        try
        {
            Renderer now_rend = Target_Root_GameObject.GetComponent<Renderer>();
            Material[] now_mats = now_rend.materials;
            for (int j = 0; j < now_mats.Length; ++j)
            {
                now_mats[j] = pink_material;
            }
            now_rend.materials = now_mats;
        }
        catch
        {
            Debug.Log("Can not pinking material");
        }
    }

    void Target_PinkOff()
    {
        try {
            Renderer now_rend = Target_Root_GameObject.GetComponent<Renderer>();
            Material[] now_mats = now_rend.materials;
            for (int j = 0; j < now_mats.Length; ++j)
            {
                now_mats[j] = Target_beforeMaterials[j];
            }
            now_rend.materials = now_mats;
        } catch
        {
            Debug.Log("Can not returning material");
        }
    }

    void Target_SaveBeforeMaterials()
    {
            try
            {
                for (int j = 0; j < Target_Root_GameObject.GetComponent<Renderer>().materials.Length; ++j)
                {
                    Target_beforeMaterials.Add(Target_Root_GameObject.GetComponent<Renderer>().materials[j]);
                }
            }
            catch
            {
                Debug.Log("Can not Saving Material");
            }
    }
    */

    void PinkOn()
    {
        for (int i = 0; i < Annotation_gameObjects_truth.Count; ++i)
        {
            Renderer now_rend = Annotation_gameObjects_truth[i].GetComponent<Renderer>();
            Material[] now_mats = now_rend.materials;
            for (int j = 0; j < now_mats.Length; ++j)
            {
                now_mats[j] = pink_material;
            }
            now_rend.materials = now_mats;
        }
    }

    void PinkOff()
    {
        for (int i = 0; i < Annotation_gameObjects_truth.Count; ++i)
        {
            Renderer now_rend = Annotation_gameObjects_truth[i].GetComponent<Renderer>();
            Material[] now_mats = now_rend.materials;
            for (int j = 0; j < now_mats.Length; ++j)
            {
                now_mats[j] = beforeMaterials[i][j];
            }
            now_rend.materials = now_mats;
        }
    }

    void SaveBeforeMaterials()
    {
        for (int i = 0; i < Annotation_gameObjects_truth.Count; ++i)
        {
            List<Material> mats = new List<Material>();
            for (int j = 0; j < Annotation_gameObjects_truth[i].GetComponent<Renderer>().materials.Length; ++j)
            {
                mats.Add(Annotation_gameObjects_truth[i].GetComponent<Renderer>().materials[j]);
            }
            beforeMaterials[i] = mats;
        }

        for (int i = 0; i < beforeMaterials.Count; ++i)
        {
            for (int j = 0; j < beforeMaterials[i].Count; ++j)
            {
                Debug.Log(beforeMaterials[i][j].name);
            }
        }
    }
}