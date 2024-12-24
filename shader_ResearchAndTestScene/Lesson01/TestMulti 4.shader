Shader "Unlit/Test_TestMulti 4"
{
    Properties
    {
        _MainTex( "Texture" , 2D ) = " white " {}
        _MixTex ( "MixTex" , 2D ) = " white " {}
        _Mask( "Mask" , 2D ) = "Black" {}
        _MipMaplod( "MipMapLevel" , Range( 0,5 ) ) = 0

        _Tiling ("Tile", float) = 1.0
        _xoffset ("Xoffset", float) = 0
        _yoffset ("Yoffset", float) = 0
        _Value ("Value", float) = 1.0
        
    }
    SubShader
    {
        Tags {
             "RenderType"="Opaque" 
             }

        Pass
        {

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #define TAU 6.28

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _MixTex;
            sampler2D _Mask;

            float4 _MainTex_ST;
            float  _MipMaplod;
            float _Tiling;
            float _xoffset;
            float _yoffset;
            float _Value;

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
                float3 worldPos : TEXCOORD2 ;
            };
            
            float InverseLerp( float a, float b, float v )
            {
                return ( v-a )/( b-a );
            }

            Interpolators vert ( MeshData v)
            {
                Interpolators o;
                o.worldPos = mul( UNITY_MATRIX_M , v.vertex );      //(unity_ObjectToWorld = UNITY_MATRIX_M)
                o.vertex = UnityObjectToClipPos(v.vertex);          //o.normal = UnityObjectToWorldNormal(v.normals);
                //o.uv = v.uv0;                                       //控制offset/Tilling
                o.uv = TRANSFORM_TEX( v.uv0, _MainTex );
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float2 Positionprojection = i.worldPos.xz;
                float4 Tex = tex2Dlod( _MainTex , float4 ( Positionprojection, _MipMaplod.xx ) );
                float4 MixTex = tex2D( _MixTex , float4 ( Positionprojection, _MipMaplod.xx ) );

                float _xMaskoffest = i.uv.x - _xoffset ;
                float _yMaskoffest = i.uv.y - _yoffset ;
                
                float2 center =  float2 ( _xMaskoffest , _yMaskoffest ) * _Tiling ;
                float4 MaskTex = tex2D( _Mask , center ).x;

                float4 finalcolor = lerp( Tex, MixTex , MaskTex );
                
                return finalcolor;
            }

            ENDCG

        }
    }
}
