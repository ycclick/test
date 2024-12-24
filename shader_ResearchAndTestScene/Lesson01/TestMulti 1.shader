Shader "Unlit/Test_TestMulti 1"
{
    Properties
    {
        _ColorA("Color A", Color) = (1,1,1,1)
        _ColorB("Color B", Color) = (1,1,1,1) 
        _ColorStart("Color Start",Range(0,1)) = 1
        _ColorEnd("Color End",Range (0,1)) = 0
        [IntRange] _Value01("Value",Range(0, 10)) = 1
        _Value02("Speed",Range(0,1)) = 0

        //_MainTex ("Texture", 2D) = "white" {}
    }
        SubShader
    {
        Tags 
        { 
            //"RenderType" = "Opaque" //不透明
            "RenderType" = "Transparent"            //渲染管線類型
            "Queue" = "Transparent"                 //渲染命令( Background, Geomertry, Alpha test, Transparent, Overlay )
        }

        Pass
        {
        //合併Blend、multiply要在CGPROGRAM前

            Cull Off
            ZWrite off
            //ZTest LEqual
            
            Blend One One //Addtive
            //Blend DstColor Zero //multiply

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
        
            #define TAU 6.28318530718

            float4 _ColorA;
            float4 _ColorB;
            float _ColorStart;
            float _ColorEnd;
            int _Value01;
            float _Value02;

            //sampler2D _MainTex;

            struct MeshData 
            {
                float4 vertex : POSITION;                                           //頂點位置
                float3 normals : NORMAL;
                float2 uv0 : TEXCOORD0;
                //float4 tangent : TANGENT;                                         //頂點用來存儲x,y,z的切線向量
                //float4 color : COLOR;                                             //頂點顏色
            };

            struct Interpolators                                                    //頂點著色器
            {
                float4 vertex : SV_POSITION; 
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
                //float2 uv : TEXCOORD0;
            };

            //方法
            

            float InverseLerp(float a, float b, float c)                            //InverseLerp(A,B,C)算遮罩間距
            {
                return(c - a) / (b - a);
            }

            Interpolators vert(MeshData v)                                          //(頂點著色)插值器傳遞數據
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);                          //頂點世界空間轉換
                o.normal = UnityObjectToWorldNormal(v.normals);                     //模型網格Normal轉換成世界座標
                o.uv = v.uv0; //( v.uv0 + _Offset ) * _Scale;

                return o;
            }
            
            float4 frag(Interpolators i) : SV_Target                                //像素著色
            {
               
            // //灰階
                // {
                //     float t = i.uv.x;
                //     return t;
                // }
                
            // //連續灰階
                // {
                //     float t = frac(i.uv.x * _Value01);
                //     t = frac(t); //frac
                //     return t;
                // }

            //波浪灰階
                {
                    float t = abs(frac(i.uv.x * _Value01) *2 - 1 );
                    return t;
                }
                
            // //硬邊
                // {
                //     float t = cos(i.uv.x * TAU * _Value01) * 3 +0.5 ;
                //     return t;
                // }
                
            // //斜線灰階
                // {
                //     float xOffset = i.uv.y ;
                //     float t = cos( (i.uv.x + xOffset) * TAU * 5) * 0.45 +0.5 ;
                //     return t;
                // }
                
            // //三角波灰階    _Time隨時間變化
                // {
                //     float xOffset = cos(i.uv.y * TAU * _Value01) * 0.03 ;
                //     float t = cos( (i.uv.x + xOffset + _Time.x*_Value01) * TAU * 5) * 0.45 +0.5 ;
                //     return t;
                // }

            // //三角波灰階    _Time隨時間變化
                // {
                //     float xOffset = cos(i.uv.x * TAU * _Value01) * 0.02 ;
                //     float t = cos( ( i.uv.y + xOffset - _Time.y * 0.1 ) * TAU * 5) * 0.5 +0.5 ;
                //     return t;
                // }

            // //顏色混合
                {
                    float t = saturate(InverseLerp( _ColorStart, _ColorEnd, i.uv.x ));
                    float4 outColor = lerp( _ColorA, _ColorB, t );
                    return outColor ;
                }

                float t = saturate(InverseLerp( _ColorStart, _ColorEnd, i.uv.x ));
                float4 outColor = lerp( _ColorA, _ColorB, t );
                return outColor ;
                
            // //UV
                // {
                //     float2 t = cos(i.uv * TAU * 2) * 0.5 + 0.5;
                //     return float4( t, 0, 1 );
                //     // return float4(i.normal,0);
                // }

            // //淡出 1-i    _Time.( x, y, z, w )( t/20, t, t*2, t*3 )
                // {
                //     float xOffset = cos(i.uv.x * TAU * _Value01) * 0.05 ;
                //     float t = cos( ( i.uv.y + xOffset - _Time.y * _Value02 ) * TAU * 5) * 0.5 +0.5 ;
                //     t *= 1 - i.uv.y ;  
                //     return t * ( abs(i.normal.y) < 0.999 );  //取該模型的0.001~0.999
                //     //return t;
                // }

            // //淡出 1-i    _Time.( x, y, z, w )( t/20, t, t*2, t*3 )
            //     {
            //         float xOffset = cos(i.uv.x * TAU * _Value01) * 0.05 ;                               //做出連續波浪條紋
            //         float t = cos( ( i.uv.y + xOffset - _Time.y * _Value02 ) * TAU * 5) * 0.5 +0.5 ;    //彎曲波浪條紋
            //         t *= 1 - i.uv.y ;                                                                   //半透明漸層 彎曲波浪條條紋

            //         float TopRemove = ( abs(i.normal.y) < 0.999 );                                      //方法:取得區間(取該模型的0.001~0.999)
            //         float waves = TopRemove * t ;                                                       //半透明漸層 彎曲波浪條條紋 取區間                

            //         float4 gradient = lerp( _ColorA, _ColorB, i.uv.y );                                 //方法:雙色混合
            //         return gradient * waves;                                                             //雙色混合 半透明漸層 彎曲波浪條條紋 取區間 

            //     }
            }
            ENDCG
        } 
    }
}