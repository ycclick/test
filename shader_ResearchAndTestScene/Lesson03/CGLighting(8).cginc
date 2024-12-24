#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING

        sampler2D _MainTex;
        float4 _MainTex_ST;
        float4 _Color;
        float _Value;
        float _Gloss;

struct MeshData
{
        float4 vertex : POSITION;
        float3 normals: NORMAL;
        float2 uv0    : TEXCOORD0;
};

struct Interpolators
{
        float4 vertex   : SV_POSITION;
        float2 uv       : TEXCOORD0;
        float3 normal   : TEXCOORD1;
        float3 wPosition: TEXCOORD2;
        LIGHTING_COORDS(3,4) 
};

Interpolators vert ( MeshData v)
{
        Interpolators o;
        o.vertex    = UnityObjectToClipPos(v.vertex);
        o.uv        = TRANSFORM_TEX(v.uv0, _MainTex);
        o.normal    = UnityObjectToWorldNormal(v.normals);
        o.wPosition = mul( unity_ObjectToWorld, v.vertex );                     //矩陣取得模型在世界中的 (float3)值
        TRANSFER_VERTEX_TO_FRAGMENT(o);             //★甚麼時候會使用?           //頂點著色器中計算的數據將被傳遞到片段著色器
        return o;
}
         
float4 frag (Interpolators i) : SV_Target
{
  #ifdef USE_LIGHTING
    //diffuse lighting  Lambertian
        float3 N            = normalize(i.normal);
        float3 L            = normalize(UnityWorldSpaceLightDir(i.wPosition));                    //worldLight平行光
      //float3 L            = _WorldSpaceLightPos0(i.wPosition));
        float  attenuation   = LIGHT_ATTENUATION (i);                                             //燈光衰退距離
        float3 lambert      = saturate( dot( N, L ) );                                            //saturate(法線與平行光取內積)
        float3 diffuseLight = (lambert * attenuation ) * _LightColor0.xyz ;                       //取得的植跟燈光混合 *atten 光線衰減

    //specular lighting  V(玩家視角) - viewvextor    R(反射) - reflect

        float3 V = normalize( _WorldSpaceCameraPos - i.wPosition ) ;                              
        // ↑ normalize 標準化向量 by chatgpt (方便用於計算光照、反射、折射，在這些計算中，只需要考慮向量的方向而不是具體的長度)
        float3 R = reflect( -L, N );                                                              //利用平行光跟法線算反射

    //Blinn - Phong

        float3 Blinn            = normalize( L + V );                                             //★worldLight平行光來的方向 + V
        float  specularLightExp = exp2 ( _Gloss * 10 ) + 2;                                       //算式控制拉桿區間
        float3 specularLight    = saturate(dot( Blinn , N )) * ( lambert > 0 );
               specularLight    = pow( specularLight, specularLightExp ) * _Gloss * attenuation ; //★Gloss在pow()外，當反射值低的時候模型的高光會逐漸擴散
               specularLight    *= _LightColor0.xyz ;
        return float4 ( diffuseLight * _Color + specularLight , 1 );                              //不希望diffuseLight與specularLight相互抑制 使用+法

    #else 
        #ifdef IS_IN_BASE_PASS
            return _Color;
        #else
            return 0;
        #endif
    #endif
}