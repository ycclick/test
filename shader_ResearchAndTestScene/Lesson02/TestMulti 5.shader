Shader "Unlit/Test_TestMulti 5"
{
    Properties
    {
        [IntRange]_HP ("HP", Range( 0 , 10 ) ) = 8
        _Health ("Health", Range( 0 , 1 ) ) = 1
        [IntRange]_Health2 ("Health2", Range( 0 , 10 ) ) = 1
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
            float _HP;
            float _Health;
            float _Health2;
            float3 _FullHP;
            float3 _LowHP;


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
                return (v-a)/(b-a);                     //計算變化的速度類型1
                //return  a * ( 1 + v ) + ( b * v );    //計算變化的速度類型2
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
                // //顏色變化
                    // float4 col = tex2D( _MainTex , i.uv );
                    // return col;

                // //一般漸層                
                //     float3 healthColor = lerp ( _LowHP, _FullHP, _Health );          // lerp 混合2個顏色
                //     float3 bgColor = float3 ( 0.01 , 0.01 , 0.01 );                  // 底色黑色
                //     float healthmask = _Health > i.uv.x ;                            // >漸層遮罩
                //     float3 final = lerp( bgColor, healthColor , healthmask );        //混合效果 healthmask作為遮罩 
                //     return float4 ( final, 1 ) ;

                // //floor
                    float4 col = tex2D( _MainTex , float2( _Health2 / 10 , i.uv.y ) );
                    float3 bg = float3 ( 0 , 0 , 0 );
                    float mask = _Health2 / 10 > float ( floor ( i.uv.x * _HP ) ) / _HP ;   //_Health2/10 > float(floor(i.uv.x*8))/8 ;
                    float3 final = lerp ( bg , col , mask );

                    return float4 ( final , 1 ) ;
                
                // // 顏色變化   clip減去
                //     float3 t = saturate(FloInverseLerp( 0 , 0.5 , _Health ));        // 換色的區間值     
                //     float3 healthColor = lerp ( _LowHP, _FullHP, t );                // lerp線性差值 上色
                //     float3 bgColor = float3 ( 0.12,0.12,0.12 );                      // 底色黑色
                //     float healthmask = _Health > i.uv.x ;                            // >漸層遮罩
                //     clip ( healthmask - 0.1 );
                //     float3 final = lerp( bgColor, healthColor , healthmask );   //混合效果 healthmask作為遮罩 
                //     return float4 ( final, 1 );



                // //針對自己設定的顏色，進行變色
                    // float3 t = saturate(FloInverseLerp( 0.1 , 0.5 , _Health ));              
                    // float3 healthColor = lerp ( _LowHP, _FullHP, t );                // lerp 混合2個顏色
                    // float3 bgColor = float3 ( 0.12,0.12,0.12 );                      // 底色黑色
                    // float healthmask = _Health > i.uv.x ;                            // >漸層遮罩
                    // float3 final = lerp( bgColor, healthColor , healthmask );        //混合效果 healthmask作為遮罩
                    // return float4 ( final, 1 );
                
            
                // //針對區間(貼圖)，進行閃爍
                //     float healMask = _Health > i.uv.x ;
                //     float3 col = tex2D( _MainTex , float2( _Health , i.uv.y ) ) ;

                //     if ( 0.15 < _Health && _Health < 0.3 )  //不可以這樣寫 → (0.15 < _Health < 0.3)
                //         {
                //             float flash = cos( _Time.y * 3 ) * 0.4 + 0.6 ;
                //             col *= flash ;
                //         }

                //     else if ( _Health < 0.15 )
                //     {
                //             float flash = cos( _Time.y * 8 ) * 0.4 + 0.6  ;
                //             col *= flash ;
                //     }
                    
                //     return float4 ( col * healMask , 1 ) ;

            }
            ENDCG
        }
    }
}
