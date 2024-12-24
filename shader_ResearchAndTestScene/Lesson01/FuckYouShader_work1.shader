    Shader "Unlit/FuckYouShader_work1"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _Value("Value",Float) = 1.0
        _Color("Color",Color) = (0,1,0.8,1)
        _Color2("Color2",Color) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Value;
            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                //float3 tanfent : TANGENT;
                //float4 color :COLOR;
                //uv0 NORMAL textures
                //uv1 lightmap
                float4 uv0 : TEXCOORD0;
                float4 uv1 : TEXCOORD1;
            };

            struct FregInput
            {
                //float2 uv0 : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
            
                float4 vertex : SV_POSITION;
                float3 normal :TEXCOORD0;
                float2 tangent : TEXCOORD1;
                float2 justSomeValue : TEXCOORD2;
                float2 uv2 : TEXCOORD3;

            };
            //float 32bit 
            //half 16bit
            //fixed lower precision -1 to 1
            float4 _Color;
            FregInput vert (MeshData v)
            {
                FregInput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //print(_Time);
                //o.normal = mul(v.normals,(float3x3) UNITY_MATRIX_MV);
                //mul((float3x3) UNITY_MATRIX_MV,v.normals);
                o.normal = v.normals;
                o.normal = UnityObjectToWorldNormal((v.normals));
                o.tangent = v.uv0;
                //o.normal = 
                //o.vertex = v.vertex;
                //o.uv0 = TRANSFORM_TEX(v.uv0, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (FregInput i) : SV_Target
            {
                // float4 mvValue = float4(1,0,0,1);
                // mvValue.y = mvValue.x/2;
                // mvValue.z = mvValue.y/2;
                // mvValue.x = mvValue.y;
                //float4 otherValue =mValue.rgba;
                
                //return mvValue;
                // return col;
                //return float4(UnityObjectToWorldNormal(i.normal),1);
                return float4(i.tangent.y,0,i.tangent.x,1);
            }
            ENDCG
        }
    }
}
