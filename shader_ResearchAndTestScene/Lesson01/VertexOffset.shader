Shader "Unlit/VertexOffset"
{
    Properties
    {
        _Value ("Value", Range(0,10)) = 2
        //_MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Blend One OneMinusSrcAlpha
        Tags 
        { 
            //"RenderType"="Opaque"
            //"Queue"="Geometry"
            "RenderType"="Transparent"
            "Queue"="Transparent"

        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define TAU 6.28318530718

            sampler2D _MainTex ;
            float4 _MainTex_ST ;
            float _Value ;

            struct MeshData
            {
                float4 vertex : POSITION;       //模型頂點位置資訊
                float3 normals : NORMAL;        //模型法線資訊
                float3 uv0 : TEXCOORD0;         //模型UV資訊
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal:TEXCOORD0;  
                float2 uv : TEXCOORD1;
            };


            //方法
            float GetWave(float2 uv)
            {
                float2 uvCentered = uv * 2 - 1 ;                                                //uv*2-1抓出中心點
                float radialDistance = length( uvCentered );                                    //中心點拉出一條等長的線
                float wave = cos( ( radialDistance - _Time.y * 0.1 ) * TAU * 5 ) * 0.5 + 0.5 ;  //拿線去x,y軸算波浪的移動量
                wave *= 1 - radialDistance;                                                     //波浪*=位移量 順便淡化外圍
                return wave;                                                                    //輸出波浪
            } 


            Interpolators vert ( MeshData v)
            {
                Interpolators o;

                v.vertex.y = GetWave(v.uv0) * _Value;

                //float wave = cos( ( v.uv0.y - _Time.y * 0.1 ) * TAU * 5 ) ;
                //v.vertex.y = wave * _Value ;

                o.vertex = UnityObjectToClipPos( v.vertex );
                o.normal = UnityObjectToWorldNormal( v.normals );
                o.uv = v.uv0;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                return GetWave( i.uv );
            }

            ENDCG

        }
    }
}
