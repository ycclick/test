Shader "Unlit/RefSkybox"
{
    Properties
    {
        _MainTex( "Texture" , 2D ) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define TAU 6.28318530718
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            struct MeshData
            {
                float4 vertex : POSITION;
                float4 normals : NORMAL;
                float3 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 uv : TEXCOORD0;
            };

            Interpolators vert ( MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv0;
                return o;
            }

            float2 DirToRectilinear(float3 dir)
            {
                float x = atan2( dir.z, dir.x )/TAU + 0.5 ;   //-tau/2,tau/2   除 TAU + 0.5 後求的值=0~1 
                float y = dir.y * 0.5 + 0.5 ; //0~1
                return float2(x,y);
            }

            float3 frag (Interpolators i) : SV_Target
            {
                float3 col = tex2Dlod( _MainTex , float4(DirToRectilinear(i.uv), 0, 0 ));
                //float3 col = tex2D( _MainTex , float4(DirToRectilinear(i.uv),0,0) );  //消除接縫
                return col;
            }
            ENDCG
        }
    }
}
