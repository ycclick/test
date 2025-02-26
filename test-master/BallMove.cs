using ETModel;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BallMove : MonoBehaviour
{
    // Start is called before the first frame update
    private Rigidbody rd;
    [SerializeField]
    private Camera cam;
    private GameObject path;
    private float moveCamera;
    void Start()
    {
        rd = this.GetComponent<Rigidbody>();
        //path
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey(KeyCode.W)) 
        {

            var pos = cam.transform.position;
            var force = Vector3.Normalize ( this.transform.position - pos); 
         
            rd.AddForce(new Vector3(force.x, 0, force.z) * Time.deltaTime*1000);
        }
        if (Input.GetKey(KeyCode.A))
        {

            var pos = cam.transform.position;
            var force = Vector3.Normalize(this.transform.position - pos);
            var rotation = Quaternion.Euler(0,-90,0);
            force = rotation *force;

            rd.AddForce(new Vector3(force.x, 0, force.z) * Time.deltaTime * 1000);
        }
        if (Input.GetKey(KeyCode.D))
        {

            var pos = cam.transform.position;
            var force = Vector3.Normalize(this.transform.position - pos);
            var rotation = Quaternion.Euler(0, 90, 0);
            force = rotation * force;

            rd.AddForce(new Vector3(force.x, 0, force.z) * Time.deltaTime * 1000);
        }
        if (Input.GetKey(KeyCode.S))
        {

            var pos = cam.transform.position;
            var force = Vector3.Normalize(this.transform.position - pos);

            rd.AddForce(-new Vector3(force.x, 0, force.z) * Time.deltaTime * 1000);
        }

    }
}
