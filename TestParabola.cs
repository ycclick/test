
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using Cinemachine;



public class TestParabola : MonoBehaviour
{
    public Camera miniCamera;
    public GameObject start;
    public GameObject center;
    public GameObject end;


    private Vector3 StartVec3;
    private Vector3 CenterVec3;
    private Vector3 EndVec3;
    private Tween DOT;
    private Object[] VirtualCamera;
    public Button button;

    private float startValue = 0;
    private float endValue = 1;
    void Awake()
    {

        StartVec3 = start.transform.position;
        CenterVec3 = center.transform.position;
        EndVec3 = end.transform.position;
        var ss = EndVec3.normalized;
        DOT = DOTween.To(setter: value => 
            {
                start.transform.position = GetBezierPoint(value,StartVec3, CenterVec3, EndVec3);
            },startValue: startValue, endValue: endValue, duration:5).SetEase(Ease.InBounce);
    
        DOT.SetAutoKill(false);
        button.onClick.AddListener(ReBall);
        //VirtualCamera = new List<CinemachineVirtualCamera>();
        //CinemachineVirtualCamera[] VirtualCameras = new CinemachineVirtualCamera[0];
        VirtualCamera = Resources.FindObjectsOfTypeAll(typeof(CinemachineVirtualCamera)) as CinemachineVirtualCamera[];
    }
    void Update()
    {
        //Log.Info("test"+ start.transform.position+"time"+ Time.deltaTime);
        //sec += Time.deltaTime;
        //if (f < 1 && sec > 0.05f)
        //{
        //    sec = 0;
        //    f += 0.01f;
        //    start.transform.position = GetBezierPoint(f, StartVec3, CenterVec3, EndVec3);

        //}

    }
    public static Vector3 GetBezierPoint(float t, Vector3 start, Vector3 center, Vector3 end)
    {
        return (1 - t) * (1 - t) * start + 2 * t * (1 - t) * center + t * t * end;
    }

    public void ReBall() 
    {

        start.transform.position = StartVec3;
        StartVec3 = start.transform.position;
        CenterVec3 = center.transform.position;
        EndVec3 = end.transform.position;
        DOT.Restart();
    }
}
