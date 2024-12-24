#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING
#define TAU 6.28318530718

    struct MeshData
{
        float4 vertex : POSITION;
        float3 normals: NORMAL;
        float4 tangent: TANGENT;        // float4(xyz = 切線方向 , w = 對應的是正反面的)
        float2 uv0    : TEXCOORD0;
};

    struct Interpolators
{
        float4 pos   : SV_POSITION;
        float2 uv       : TEXCOORD0;
        float3 normal   : TEXCOORD1;    //float3(像素著色器可以忽略掉正反)
        float3 tangent  : TEXCOORD2;
        float3 bitangent: TEXCOORD3;
        float3 wPosition: TEXCOORD4;
    #ifdef IS_IN_BASE_PASS
        SHADOW_COORDS(5)
    #elif defined (IS_IN_Add_PASS)
        LIGHTING_COORDS(6,7) 
    #endif
   
};
        sampler2D _Maintex;      
        sampler2D _Normalmap;
        //sampler2D _Heightmap;
        sampler2D _DifSpeIBL;          //skybox貼圖 模糊
        //sampler2D _SpecularIBL;         //skybox貼圖 高清  如果要使用reflect prob 可以刪除Properties的_SpecularIBL,加入shader.set Global texture
        sampler2D _GlossMask;
        float4 _Maintex_ST;              //sampler2D跟_ST的名稱要一致
        float4 _Color;
        float  _Gloss;
        float  _NormalIntensity;
        float  _DiffuseIBLIntensity;
        float  _SpecularIBLIntensity;

        float2 DirToRectilinear(float3 dir)
        {
            float x = atan2( dir.z, dir.x )/TAU + 0.5 ;   //-tau/2,tau/2   除 TAU + 0.5 後求的值=0~1 
            float y = dir.y * 0.5 + 0.5 ;                 //0~1
            return float2(x,y);
        }

    Interpolators vert ( MeshData v)
{
            Interpolators o;
            o.uv          = TRANSFORM_TEX(v.uv0, _Maintex);
            //float height  = tex2Dlod( _Heightmap , float4( o.uv, 0, 0 ) ).x * 2 - 1 ; //float(o.uv分別對應uv的xy軸, 採樣的中間階段, 最高階段)      
            o.normal      = UnityObjectToWorldNormal(v.normals);
            o.tangent     = UnityObjectToWorldDir(v.tangent.xyz);
            o.bitangent   = cross( o.normal, o.tangent ); 
            o.bitangent  *= v.tangent.w * unity_WorldTransformParams.w ;                //正確翻轉正反面
            o.pos      = UnityObjectToClipPos(v.vertex);                                //在有頂點偏移的情況下需要先計算完偏移再輸出
            o.wPosition = mul( unity_ObjectToWorld, v.vertex ).xyz;                     //矩陣取得模型在世界中的 (float3)值
        #ifdef IS_IN_BASE_PASS
            TRANSFER_SHADOW(o);
        #elif defined (IS_IN_Add_PASS)
            TRANSFER_VERTEX_TO_FRAGMENT(o);                                             //頂點著色器中計算的數據將被傳遞到片段著色器
        #endif

        return o;
}
         
    float4 frag (Interpolators i) : SV_Target
{   
    //表面著色
        float4   maintex      = tex2D( _Maintex , i.uv ) ;
        float3   surfaceColor = maintex.rgb * _Color.rgb ;

    //Normal        //UnpackNormal(tangent - X, bitangent - Y, normal - Z)
        float3   tangentSpaceNormal = UnpackNormal( tex2D( _Normalmap , i.uv )); 
                 tangentSpaceNormal = normalize( lerp ( float3(0,0,1), tangentSpaceNormal, _NormalIntensity)); 
        float3x3 mtxTangentToWorld =
        {
            i.tangent.x, i.bitangent.x, i.normal.x,
            i.tangent.y, i.bitangent.y, i.normal.y,
            i.tangent.z, i.bitangent.z, i.normal.z
        };  
        float3  N = mul( mtxTangentToWorld , tangentSpaceNormal );

    #ifdef USE_LIGHTING
    //diffuse lighting  Lambertian                       
        float3  L            = normalize(UnityWorldSpaceLightDir(i.wPosition));         //L = worldLight平行光
        float   attenuation  = LIGHT_ATTENUATION (i);                                   //燈光衰退距離
        //UNITY_LIGHT_ATTENUATION(attenuation, i, i.wPosition);//包含光照衰减以及阴影
        float3  lambert      = saturate( dot( N, L ) );                                 //saturate(法線與平行光取內積)
        float3  diffuseLight = (lambert * attenuation ) * _LightColor0.xyz ;
        float3  V            = normalize( _WorldSpaceCameraPos - i.wPosition ) ;        //V(玩家視角)
        float3  R            = reflect( -L, N );                                        //R(反射) - reflect

    //Blinn - Phong
        float3  Blinn            = normalize( L + V );                                   //平行光 + 玩家視角
        float   specularLightExp = exp2 ( _Gloss * 7 ) + 2;                             //算式控制拉桿區間
        float3  specularLight    = saturate(dot( Blinn , N )) * ( lambert > 0 );
                specularLight    = pow( specularLight, specularLightExp ) * _Gloss * attenuation ; //★Gloss在pow()外，當反射值低的時候模型的高光會逐漸擴散
                specularLight   *= _LightColor0.xyz ;

        #ifdef IS_IN_BASE_PASS
        //環境光漫反射
            float3 diffuseIBL     = tex2Dlod ( _DifSpeIBL , float4(DirToRectilinear( N ),8,8 ) ).xyz;                           // i.normal 換成 矩陣轉換後的 N
                   diffuseLight  += diffuseIBL * _DiffuseIBLIntensity;                                                           //漫反射 + 環境光 = 環境光漫反射

            //float  fresnel        = pow( 1 - saturate(dot(V,N)) , 2 );
            float3 viewReflect    = reflect( -V , N );

            float3 glossmask      = tex2D( _GlossMask , i.uv );
            //float  glossMip       = ( 1 - _Gloss ) * 5 ;
            //float3 specularIBL    = tex2Dlod ( _DifSpeIBL , float4(DirToRectilinear( viewReflect ),  ( _SpecularIBLIntensity * 2 ) + 1 ,  ( _SpecularIBLIntensity * 2 ) + 1  ) ).xyz;
            float3 specularIBL    = tex2Dlod ( _DifSpeIBL , float4(DirToRectilinear( viewReflect ), 5,5 ) ).xyz;
            float3 MaskSpIBL      =  _Gloss * specularIBL * glossmask ;
                   specularLight += MaskSpIBL  * _SpecularIBLIntensity;
        #endif
        
        return float4 ( (diffuseLight  * surfaceColor  + specularLight ) , 1 ) ;              //不希望diffuseLight與specularLight相互抑制 使用+法

    #else 
        #ifdef IS_IN_BASE_PASS
            return 0;
        #else
            return 0;
        #endif
    #endif
}