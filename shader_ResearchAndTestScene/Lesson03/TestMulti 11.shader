Shader "Unlit/Test_TestMulti 11"
{
    Properties
    {
        _Color   ( "顏色" , Color ) = ( 1 , 1 , 1 , 1 )
        _Maintex ( "主貼圖" , 2D ) = "white" {}
        [NoScaleOffset] _Normalmap ( "法線貼圖" , 2D )= "bump" {}
        _NormalIntensity   ( "法線強度" , Range( 0, 1 ) ) = 0.5
        [NoScaleOffset] _DifSpeIBL ( "漫反射全反射貼圖(天空盒)" , 2D ) = "bump" {}
        _DiffuseIBLIntensity ( "漫反射強度" , Range( 0, 1 )) = 0
        [NoScaleOffset] _GlossMask ( "全反射遮罩" , 2D ) = "gray" {}
        //[NoScaleOffset] _SpecularIBL ( "全反射貼圖" , 2D ) = "black" {}
        _SpecularIBLIntensity ( "全反射強度" , Range( 0, 1 )) = 0
        _Gloss   ( "高光" , Range( 0, 1 ) ) = 0.5 
        
    }
    
    SubShader
    { 
        Tags { "RenderType"="Opaque" "Queue" = "Geometry" }  
       
        //Base pass
        Pass
        {
            Tags{ "LightMode" = "ForwardBase" }

            CGPROGRAM   
            
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #define IS_IN_BASE_PASS
            #include "CGLightingV1.0.cginc"
            ENDCG
        }

        //Add pass
        Pass
        {
            Tags{ "LightMode" = "ForwardAdd" }
            
            Blend One One //src*1 + dst*1
            CGPROGRAM   
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows        //★多重編譯前向添加  
            #define IS_IN_Add_PASS          
            #include "CGLightingV1.0.cginc"
            ENDCG
        }      

        Pass
		{
			Tags { "LightMode" = "ShadowCaster" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing // allow instanced shadow pass for most of the shaders
            #pragma USE_LIGHTING 
			#include "UnityCG.cginc"

            //sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _Color;
            //half _Cutoff;

			struct Interpolators {
				V2F_SHADOW_CASTER;
				//float2  uv : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			Interpolators vert(appdata_base v)
			{
				Interpolators o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				//o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			float4 frag(Interpolators i) : SV_Target
			{
				//fixed4 maintex = tex2D( _MainTex, i.uv );

				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
    }
}