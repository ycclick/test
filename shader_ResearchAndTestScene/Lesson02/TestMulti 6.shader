Shader "Unlit/Test_TestMulti 6"
{
    Properties
    {
        _Value ("OutLine", Range ( 0 , 1 )) = 0.1
        _Health ("Health", Range( 0 , 1 ) ) = 1
        _FullHP ("FullHPColor", Color ) = (0,1,0)
        _LowHP ("LowHPColor", Color ) = (1,0,0)
        [NoScaleOffset]_MainTex( "Texture" , 2D ) = "white" {}
    }
    SubShader
    {
        Tags 
        {
            //"RenderType" = "Opaqe"
            "RenderType" = "Transparent" 
            "Queue" = "Transparent"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Health;
            float3 _FullHP;
            float3 _LowHP;
            float _Value;


            struct MeshData
            {
                float4 vertex : POSITION;
                float4 normals : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float FloInverseLerp( float a , float b , float v ) 
            {
                return (v-a)/(b-a);
            };

            int IntInverseLerp( float a , float b , float v ) 
            {
                return (v-a)/(b-a);
            };
           
            Interpolators vert ( MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv0, _MainTex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {  
            // //以灰階數量排出總長 總長取每一段中間值 拉出頭尾長度 clip減掉多餘的部分
            //     float2 gradient = i.uv;
            //     gradient.x *= 30;

            //     float2 centerpoint = float2( clamp( gradient.x , 0.5 , 29.5 ) , 0.5 );  //求中心點 0.5~9.5 (clamp限制x軸的單位)
            //     float centerlength = distance( gradient , centerpoint ) * 2 - 1 ;       //從中心點往外延伸
            //     clip (-centerlength);                                                   //clip 減去
            //     float outline = ( centerlength + _Value );
                
            // //反鋸齒 fwidth() 螢幕空間偏微分(screen space partial derivate) ??? 
            //     float smoothblur = fwidth( outline ) ;
            //     float outlineMask = 1 - saturate(outline / smoothblur) ;
            //     //length( float2 ( ddx( ) ddy( ) ));    
            //     //float outlineMask = step( 0 , -outline );
                
            //     //return float4 ( outlineMask.xxx , 1 ) ;
            //     //return float4 ( centerlength.xxx ,1) ;
                
            // //針對區間進行閃爍

            //     float healMask = _Health > i.uv.x ;
            //     float3 col = tex2D( _MainTex , float2( _Health , i.uv.y ) ) ;            
            //     // ↑ 不用 i.uv 而是 float2( _Health , i.uv.y ) 取_MainTex貼圖 當下值(uv.y軸) 的顏色
            // //條件(一般邏輯判斷會交給CPU而非GPU)  #不可以這樣寫 → (0.15 < _Health < 0.3)
            //     if ( 0.15 < _Health && _Health < 0.3 )                                  
            //     {
            //         float flash = cos( _Time.y * 3 ) * 0.4 + 0.6 ;
            //         col *= flash ;
            //     }

            //     else if ( _Health < 0.15 )
            //     {
            //         float flash = cos( _Time.y * 8 ) * 0.4 + 0.6  ;
            //         col *= flash ;
            //     }

            //     return float4 ( col * healMask * outlineMask , 1 ) ;
            //     //return float4(centerlength.xxx,1);


                //以灰階數量排出總長 總長取每一段中間值 拉出頭尾長度 clip減掉多餘的部分
                    float2 gradient = i.uv;
                    gradient.x *= 30;

                    float2 centerpoint = float2( clamp( gradient.x , 0.5 , 29.5 ) , 0.5 );  //求中心點 0.5~9.5 (clamp限制x軸的單位)
                    float centerlength = distance( gradient , centerpoint ) * 2 - 1 ;       //從中心點往外延伸
                    clip (-centerlength);                                                   //clip 減去
                    float outline = ( centerlength + _Value );

                //反鋸齒 fwidth() 螢幕空間偏微分(screen space partial derivate) ??? 
                    float smoothblur = fwidth( outline ) ;
                    float outlineMask = 1 - saturate(outline / smoothblur) ;
                    float healMask = _Health > i.uv.x ;
                    float3 col = tex2D( _MainTex , float2( _Health , i.uv.y ) ) ;            
                    // ↑ 不用 i.uv 而是 float2( _Health , i.uv.y ) 取_MainTex貼圖 當下值(uv.y軸) 的顏色
                    
                    if ( 0.15 < _Health && _Health < 0.3 )                                  
                {
                    float flash = cos( _Time.y * 3 ) * 0.4 + 0.6 ;
                    col *= flash ;
                }

                else if ( _Health < 0.15 )
                {
                    float flash = cos( _Time.y * 8 ) * 0.4 + 0.6  ;
                    col *= flash ;
                }

                return float4 ( col * healMask * outlineMask , 1 ) ;

            }
            ENDCG
        }
    }
}
