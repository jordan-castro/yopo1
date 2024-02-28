using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using System.Runtime.InteropServices;

public class Plugin : MonoBehaviour
{
    [DllImport("NativeMonitor")]
    public static extern void NativeMonitor_StartTracking();
    [DllImport("NativeMonitor")]
    public static extern void NativeMonitor_StopTracking();

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        
    }

    // On Start button click
    public void OnStartButtonClick()
    {
        StartTracking();
    }

    // On Stop button click
    public void OnStopButtonClick()
    {
        StopTracking();
    }

    private void StartTracking()
    {
        NativeMonitor_StartTracking();
    }

    private void StopTracking()
    {
        NativeMonitor_StopTracking();
    }
}
