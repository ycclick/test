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
        float4 vertex   : SV_POSITION;
        float2 uv       : TEXCOORD0;
        float3 normal   : TEXCOORD1;    //float3(像素著色器可以忽略掉正反)
        float3 tangent  : TEXCOORD2;
        float3 bitangent  : TEXCOORD3;
        float3 wPosition: TEXCOORD4;
        LIGHTING_COORDS(5,6) 
};

        sampler2D _Albedo;      
        sampler2D _Normalmap;
        sampler2D _Heightmap;
        sampler2D _DiffuseIBL;           //skybox貼圖 模糊
        sampler2D _SpecularIBL;         //skybox貼圖 高清  如果要使用reflect prob 可以刪除Properties的_SpecularIBL,加入shader.set Global texture
        float4 _Albedo_ST;              //sampler2D跟_ST的名稱要一致
        float4 _Color;
        float4 _AmbientLight;
        float  _Value1;
        float  _Value2;
        float  _Gloss;
        float  _NormalIntensity;
        float  _DisplaceIntensity;

        float2 DirToRectilinear(float3 dir)
        {
            float x = atan2( dir.z, dir.x )/TAU + 0.5  ;   //-tau/2,tau/2   除 TAU + 0.5 後求的值=0~1 
            float y = dir.y * 0.5 + 0.5 ;                   //0~1
            return float2(x,y);
        }

    Interpolators vert ( MeshData v)
{
        Interpolators o;
        o.uv          = TRANSFORM_TEX(v.uv0, _Albedo);
        float height  = tex2Dlod( _Heightmap , float4( o.uv, 0, 0 ) ).x * 2 - 1 ;   //float(o.uv分別對應uv的xy軸, 採樣的中間階段, 最高階段)
        v.vertex.xyz += v.normals * height * _DisplaceIntensity ;                   //v.vertex.xyz網格偏移沿著normal的方向
        o.vertex      = UnityObjectToClipPos(v.vertex);                             //在有頂點偏移的情況下需要先計算完偏移再輸出
        o.normal      = UnityObjectToWorldNormal(v.normals);
        o.tangent     = UnityObjectToWorldDir(v.tangent.xyz);
        o.bitangent   = cross( o.normal, o.tangent ); 
        o.bitangent  *= v.tangent.w * unity_WorldTransformParams.w ;                //正確翻轉正反面
        o.wPosition = mul( unity_ObjectToWorld, v.vertex );                         //矩陣取得模型在世界中的 (float3)值
        TRANSFER_VERTEX_TO_FRAGMENT(o);                         //★甚麼時候會使用?   //頂點著色器中計算的數據將被傳遞到片段著色器
        return o;
}
         
    float4 frag (Interpolators i) : SV_Target
{   
    
    //表面著色
        float3 albedo       = tex2D( _Albedo , i.uv ).rgb ;
        float3 surfaceColor = albedo * _Color.rgb ;

    //Normal
        float3 tangentSpaceNormal = UnpackNormal( tex2D( _Normalmap , i.uv )); //UnpackNormal把3個分量拆開
        //一般情況下 tangent - X, bitangent - Y, normal - Z
        tangentSpaceNormal = normalize( lerp ( float3(0,0,1), tangentSpaceNormal, _NormalIntensity)); 
        // lerp (float3(0,0,1)平坦 與 tangentSpaceNormal現有的貼圖), 目的：_NormalIntensity控制強度
        float3x3 mtxTangentToWorld =
        {
            i.tangent.x, i.bitangent.x, i.normal.x,
            i.tangent.y, i.bitangent.y, i.normal.y,
            i.tangent.z, i.bitangent.z, i.normal.z
        };  //float3x3 計算xyz的 (tangent , bitangent , normal)

        float3 N = mul( mtxTangentToWorld , tangentSpaceNormal );
    #ifdef USE_LIGHTING
    //diffuse lighting  Lambertian
        //float3 N          = normalize(i.normal);                                                
        float3 L            = normalize(UnityWorldSpaceLightDir(i.wPosition));
        //float3 L          = _WorldSpaceLightPos0(i.wPosition));  L = worldLight平行光
        float  attenuation  = LIGHT_ATTENUATION (i);                                              //燈光衰退距離
        float3 lambert      = saturate( dot( N, L ) );                                            //saturate(法線與平行光取內積)
        float3 diffuseLight = (lambert * attenuation ) * _LightColor0.xyz ;                       //取得的植跟燈光混合 *atten 光線衰減

    //環境光漫反射
        // #ifdef IS_IN_BASE_PASS // v1.0 (最簡單的漫反射樣式但不真實)
        //     diffuseLight += _AmbientLight; //漫反射 + 環境光 = 環境光漫反射(只應用在環境光只發生在base pass)
        // #endif
        #ifdef IS_IN_BASE_PASS    // v2.0
            float3 diffuseIBL = tex2Dlod ( _DiffuseIBL , float4(DirToRectilinear( N ),0,0 ) ).xyz; // i.normal 換成 矩陣轉換後的 N
            diffuseLight     += diffuseIBL; //漫反射 + 環境光 = 環境光漫反射(只應用在環境光只發生在base pass)(最簡單的漫反射樣式但不真實)
        #endif

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

        #ifdef IS_IN_BASE_PASS 
               float3 viewReflect = reflect( -V , i.normal);
               float  glossMip    = ( 1 - _Gloss ) * 5 ;
               float3 specularIBL = tex2Dlod ( _SpecularIBL , float4(DirToRectilinear( viewReflect ),glossMip,glossMip ) ).xyz;
               specularLight     += specularIBL;
        #endif

        return float4 ( diffuseLight * surfaceColor + specularLight , 1 );                        //不希望diffuseLight與specularLight相互抑制 使用+法

    #else 
        #ifdef IS_IN_BASE_PASS
            return 0;
        #else
            return 0;
        #endif
    #endif
}