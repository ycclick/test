using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
    // Start is called before the first frame update
    public 
    void Awake()
    {
        int totalSeconds = 65;

        // 將秒數轉為 TimeSpan
        TimeSpan timeSpan = TimeSpan.FromSeconds(totalSeconds);

        string timeString = timeSpan.ToString(@"mm\:ss");

        Debug.Log(timeString);
    }


}
