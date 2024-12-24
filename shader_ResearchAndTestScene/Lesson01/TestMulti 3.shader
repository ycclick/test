Shader "Unlit/Test_TestMulti 3"
{
    Properties
    {
        _MainTex( "Texture" , 2D ) = "white" {}
        _Pattern( "Pattern" , 2D ) = "white" {}
        [IntRange]_Value ("Value", range(1,10)) = 5

        [IntRange] _Amount ( "_Amount" , Range( 0,10 ) ) = 1
        _Speed ( "_Speed" , Range( 0,10 ) ) = 0
        _Strength ( "_Strength" , Range( -5,5 ) ) = 2
        
    }
    SubShader
    {
        Tags
         {
            "RenderType"="Opaque" 
         }

        Pass
        {

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #define TAU 6.28
            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION ;
                float4 normals : NORMAL ;
                float2 uv0 : TEXCOORD0 ;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION ;
                float3 normal : TEXCOORD0 ;
                float2 uv : TEXCOORD1 ;
                float4 worldPos : TEXCOORD2 ;
            };

            sampler2D _MainTex;
            sampler2D _Pattern;
            float4 _MainTex_ST;
            float _Value;

            float _Amount;              //波的數量
            float _Speed;               //波的速度
            float _Strength;            //波的強度


            float GetWave( float2 inputuv )
            {
                float wave = cos ( inputuv * TAU * _Amount + ( _Time.y * _Speed ) ) * 0.5 + 0.5 ;
                wave *= 1 - inputuv ;
                return wave;
            };
            float InverseLerp(float a, float b, float c)                            //InverseLerp(A,B,C)算遮罩間距
            {
                return(c - a) / (b - a);
            }
            

            Interpolators vert ( MeshData v)
            {
                Interpolators o;

                o.worldPos = mul( UNITY_MATRIX_M , float4( v.vertex.xyz ,1 ) );  //運算矩陣  MATRIX_M = ObjectToWorld  從Local Space轉換到World Space

                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.normal = UnityObjectToWorldNormal(v.normals);
                o.uv = TRANSFORM_TEX( v.uv0 , _MainTex );
                //o.uv.x *= _Time.y;

                //o.uv.x += _Time.y * 0.1;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            { 
                float2 TexProjection = i.worldPos.xz;                           //投影貼圖到模型
                
                float4 Tex = tex2D ( _MainTex , TexProjection/_Value ) ;        //依據投影置入需要的貼圖

                float pattern = tex2D ( _Pattern , i.uv ) ;                     //遮罩


                float4 final = lerp( float4(1,1,1,1) , Tex , pattern );
                //float2 GetWave( pattern);

                return final ;
            }

            ENDCG

        }
    }
}
