Shader "Unlit/Test_TestMulti 7"
{
    Properties
    {
        _MainTex( "Texture" , 2D ) = "white" {}
        _Color( "Color" , Color ) = ( 1 , 1 , 1 , 1 )
        _Value ( "Value" , float ) = 1.0
        _Gloss( "Gloss" , Range( 0, 1 ) ) = 0.5
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
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Value;
            float _Gloss;
            
            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 wPosition : TEXCOORD2;
            };

            Interpolators vert ( MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv0, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normals);
                o.wPosition = mul( unity_ObjectToWorld, v.vertex );                        //矩陣取得模型在世界中的 (float3)值
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                //diffuse lighting  Lambertian
                    float3 N = normalize(i.normal);                                         
                    float3 L = _WorldSpaceLightPos0.xyz;                                   //worldLight平行光
                    //float3 diffuseLight = dot( N, L );
                    //float3 diffuseLight = max(dot( N, L ));
                    float3 lambert = saturate( dot( N, L ) );                              //saturate(法線與平行光取內積)
                    float3 diffuseLight = lambert * _LightColor0.xyz ;                     //取得的植跟燈光混合
                
                //specular lighting  V(玩家視角) - viewvextor    R(反射) - reflect

                    //float3 V = _WorldSpaceCameraPos - i.wPosition ;                      //這是向量從物體表面指向相機 指向性相機 
                    float3 V = normalize( _WorldSpaceCameraPos - i.wPosition ) ;           //normalize 標準化向量 by chatgpt (方便用於計算光照、反射、折射，在這些計算中，只需要考慮向量的方向而不是具體的長度)
                    float3 R = reflect( -L, N );                                           //利用平行光跟法線算反射

                //Blinn - Phong

                    float3 Blinn = normalize( L + V );                                     //★worldLight平行光來的方向 + V
                    float specularLightExp = exp2 ( _Gloss * 10 ) + 2;                     //算式控制拉桿區間

                    float3 specularLight = saturate(dot( Blinn , N )) * ( lambert > 0 );
                    specularLight = pow( specularLight, specularLightExp ) * _Gloss;       //★Gloss在pow()外，當反射值低的時候模型的高光會逐漸擴散

                    //float3 specularLight = saturate(dot( V , R )); 
                    //specularLight = pow( specularLight, specularLightExp );
                    specularLight *= _LightColor0.xyz ;
                    //return float4 ( diffuseLight * _Color + specularLight , 1 );             //不希望diffuseLight與specularLight相互抑制 使用+法

                //Fresnel
                
                    float fresnel = 1 - dot( N , V );
                    //float fresnel = step( 0.6 , 1 - dot( N , V ) );

                    return float4 ( diffuseLight * _Color + specularLight + fresnel * _Value , 1 );

            }
            ENDCG
        } 

    }
}
