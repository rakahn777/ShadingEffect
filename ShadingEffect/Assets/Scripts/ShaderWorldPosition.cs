using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderWorldPosition : MonoBehaviour
{

    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalVector("_Position", transform.position);
    }
}
