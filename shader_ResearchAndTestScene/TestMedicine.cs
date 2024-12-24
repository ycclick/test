
using UnityEngine;
using DG.Tweening;
using ETModel;
using System;
using System.Collections.Generic;
using System.Collections;
using Random = UnityEngine.Random;
using UnityEngine.UI;


public class TestMedicine : MonoBehaviour
{
    #region 常數
    [SerializeField]
    private readonly List<float> stirProgressBouns = new List<float>() {0, 0.5f, 1.1f, 1.3f };
    [SerializeField]
    private readonly List<float> fireProgressBouns = new List<float> { 0,1, 1.5f, 2 };
    private readonly List<float> fireRange = new List<float> { 0, 0.4f, 0.7f };
    private readonly List<string> fireTextRange = new List<string>() { "無火", "小火", "中火", "大火" };
    #endregion

    private int mixDescendLimit;
    private int mixDescendPerSecond;
    ///完成度
    [SerializeField]
    private Image ImgCompletionBar;
    [SerializeField]
    private float completionValue;
    #region 火力+ 燒焦
    private float fireValue;
    //火力影響加成
    //火力值
    [SerializeField]
    private float firePower;
    private float FirePower
    {
        get
        {
            return firePower;
        }
        set
        {

            var speed = BarMoveSpeedlimit(firePower, value);
            firePower = Mathf.Clamp01(value);
            fireImgBar.DOFillAmount(
                firePower, 1f * speed / 2).OnComplete(() => { FireLevel(firePower); }).SetEase(Ease.Linear);
        }
    }
    
    [SerializeField]
    private Image fireImgBar;
    [SerializeField]
    private Text fireText;
    //火力值上限
    private const float fireLimit = 1;
    //燒焦值
    private float scorchValue;
    //燒焦值上限
    private const float scorchLimit = 1;
    #endregion
    #region 攪拌控制
    private bool ProgressIsMove = false;
    //UI物件攪拌
    [SerializeField]
    private GameObject StirObject;


    [SerializeField]
    private List<int> stirRange = new List<int>();
    [SerializeField]
    private int stirRangeValue;
    [SerializeField]
    private GameObject StirIndexObject;
    [SerializeField]
    private float StirIndexInitialPos;
    [SerializeField] 
    private float stirIndexValue = 0;
    private float StirIndexValue
    {
        get
        {
            return stirIndexValue;
        }
        set
        {
            var StirIndexPos = StirIndexObject.GetComponent<Transform>();
            if (CheackDoTween(StirIndexPos.gameObject)) return;

            var speed = BarMoveSpeedlimit(stirIndexValue,value);

            stirIndexValue = Mathf.Clamp01(value);
            
            StirIndexPos.DOMoveX(stirRangeValue * stirIndexValue + StirIndexInitialPos, 1f * speed / 2, false).OnComplete(
                () =>{ProgressIsMove = false;}).OnStart(() => { ProgressIsMove = true; })
                .SetEase(Ease.Linear);
        }
    }


    #endregion
    #region 攪拌加成控制
    ///攪拌加成範圍
    [SerializeField]
    private GameObject StirFullBounsObject;
    [SerializeField]
    private GameObject StirNormalBounsObject;
    //攪拌值加成範圍
    [SerializeField]
    private GameObject StirBounsObjectLoction;

    private float StirBounsLocationValue;
    RectTransform StirFullBouns;
    RectTransform StirNormalBouns;
    //攪拌值加成範圍
    [SerializeField]
    private List<float> stirBounsRange = new List<float>();
    [SerializeField]
    private float mixValue = 0;
    [SerializeField]
    public float MixValue 
    {
        get 
        { 
            return mixValue; 
        }
        set 
        {
          
            var speed = (Math.Abs(mixValue - value)) / (stirBounsRangs[1] - stirBounsRangs[0]);
            mixValue = value;
            var StirAnchoredPos = StirBounsObjectLoction.GetComponent<Transform>();
            StirAnchoredPos.DOMoveX(stirRangeValue * mixValue + StirBounsLocationValue,speed, false)
                .OnComplete(
                () => 
                {
                    var range = Random.Range(stirBounsRangs[0], stirBounsRangs[1]);
                    MixValue = range;
                }
                ).SetEase(Ease.Linear);
        }
    }
    private bool IsStirring = false;
    //攪拌加成範圍
    public List<float> stirBounsRangs = new List<float>();
    #endregion
    //吃企劃表
    private int time = 120;
    private Action Stir;
    #region 藥水
    //藥瓶種類
    private enum MedicineBottle
    {
        Medicine1 = 1,
        Medicine2 = 2,
        Medicine3 = 3,
        Medicine4 = 4,
        Medicine5 = 5,
        Medicine6 = 6,
        Medicine7 = 7,
        Medicine8 = 8
    }
    [SerializeField]
    private List<Sprite> Potion;
    [SerializeField]
    private Image Imag_Potion;
    #endregion

    private void Awake()
    {
        InitStir();
        InitFire();
        InitPostion();
        InitProgress();
        GamerTimer(time);

    }
    private void InitStir() 
    {
        InitStirIndex();
        InitStirBouns();

    }
    private void InitStirIndex() 
    {
        StirIndexInitialPos = StirIndexObject.transform.position.x;

    }
    private void InitStirBouns() 
    {
        StirBounsLocationValue = StirBounsObjectLoction.transform.position.x;

        var rect = StirObject.GetComponent<RectTransform>();
        stirRange.Add((int)-rect.GetWidth() / 2);
        stirRange.Add((int)rect.GetWidth() / 2);
        stirRangeValue = (int)rect.GetWidth();
        stirBounsRangs.Add(0.50f);
        stirBounsRangs.Add(0.60f);

        MixValue = stirBounsRangs[0];
        StirFullBouns = StirFullBounsObject.GetComponent<RectTransform>();
        StirNormalBouns = StirNormalBounsObject.GetComponent<RectTransform>();
        StirFullBouns.SetWidth(stirRangeValue * 0.3f * 0.6f);
        Log.Info("size"+ StirFullBouns.sizeDelta.x);
        StirNormalBouns.SetWidth(stirRangeValue * 0.6f);
        Log.Info("size" + StirNormalBouns.sizeDelta.x);
    }
    private void InitFire() 
    {

    }
    private void InitPostion() 
    {
        var InitPotion = Random.Range(0, Potion.Count - 1);
        Imag_Potion.sprite = Potion[InitPotion];
    }
    private void InitProgress() 
    {
        completionValue = ImgCompletionBar.fillAmount;
    }
    private void ScorchInit() 
    {

    }
    void Update()
    {
        if (Input.GetKey("a"))
        {
            IsStirring = true;
        }
        else
        {
            IsStirring = false;

        }
        if (!ProgressIsMove)
        {
            if (StirIndexValue <= 1f && IsStirring == true)
            {
                StirIndexValue = StirIndexValue + 0.15f;
            }
            else if (StirIndexValue > 0)
            {
                StirIndexValue = StirIndexValue - 0.05f;
            }
            FireControl(!IsStirring);
        }
        IndexBounsCompare();
    }
    /// <summary>
    /// 火力值的上升下降
    /// </summary>
    private void FireControl(bool isMakeFire) 
    {
        if (!DOTween.IsTweening(fireImgBar))
        {
            FirePower = isMakeFire ? FirePower + 0.15f : FirePower - 0.05f;
        }
    }
    private void FireLevel(float fireVel) 
    {
        int fireLevel = 0;
        foreach (var fire in fireRange) 
        {
            if (fireVel > fire) 
            {
                fireLevel++;
            }
        }
        fireValue = fireProgressBouns[fireLevel];
        fireText.text = fireTextRange[fireLevel];
    }
    
    //比對 指標位置 指標是否位於範圍內
    private void IndexBounsCompare() 
    {
        var xd = StirBounsObjectLoction.GetComponent<RectTransform>();
        StirBounsWidthRange(StirBounsObjectLoction.transform, StirFullBouns.sizeDelta.x,out List<float> stirFullBounsRange);
        StirBounsWidthRange(StirBounsObjectLoction.transform, StirNormalBouns.sizeDelta.x, out List<float> stirNormalBounsRange);
        float StirValue;
        if (stirFullBounsRange[0] < StirIndexObject.transform.position.x &&
            StirIndexObject.transform.position.x < stirFullBounsRange[1])
        {
            StirValue = stirProgressBouns[3];
            Log.Info("Full");
        }
        else if (stirNormalBounsRange[0] < StirIndexObject.transform.position.x &&
            StirIndexObject.transform.position.x < stirNormalBounsRange[1])
        {
            StirValue = stirProgressBouns[2];
            Log.Info("Normal");
        }
        else
        {
            StirValue = stirProgressBouns[1];
            Log.Info("Nop");
        }
        completionValue += StirValue * fireValue;
    }
    private void StirBounsWidthRange(Transform StirBounsLoction, float BounsWidth, out List<float> BounsRange) 
    {
        BounsRange = new List<float>();
        BounsRange.Add(StirBounsLoction.position.x  - BounsWidth/2);
        BounsRange.Add(StirBounsLoction.position.x  + BounsWidth/2);

    }
    private bool CheackDoTween(GameObject TweenObject) 
    {
        return DOTween.IsTweening(TweenObject);
    }
    /// <summary>
    /// 計算Bar的基礎移動距離再根據Clamp01為上下限算出移動小於厡數值時的正確移動速度
    /// </summary>
    /// <param name="value"></param>
    /// <param name="move"></param>
    /// <returns></returns>
    private float BarMoveSpeedlimit(float value,float move) 
    {
        //移動距離
        var speed = Mathf.Abs( value - move);
        move = Mathf.Abs(value - Mathf.Clamp01(move));
        speed = Mathf.Abs(move /speed);
        return speed;
    }
    async private void GamerTimer(int time ) 
    {
        var startTime = time;
        while (startTime > 0) 
        {
            startTime--;
            //await ETModel.Game.Scene.GetComponent<TimerComponent>().WaitForSecondAsync(1);
            if (startTime.Equals(0)) 
            {
                break;
            }
        }
    }
    private void EndGame() 
    {

    }
    public void ReBall() 
    {


    }
}
