Shader "Unlit/Test_TestMulti 10"
{
    Properties
    {
        _Albedo ( "Albedo" , 2D ) = "white" {}
        _Color   ( "Color" , Color ) = ( 1 , 1 , 1 , 1 )
        [NoScaleOffset] _Normalmap ( "Normal" , 2D )= "bump" {}
        [NoScaleOffset] _Heightmap ( "Height" , 2D )= "gray" {}
        [NoScaleOffset] _DiffuseIBL ( "Diffuse IBL" , 2D ) = "black" {}
        [NoScaleOffset] _SpecularIBL ( "Specular IBL" , 2D ) = "black" {}
        _NormalIntensity   ( "NormalIntensity" , Range( 0, 1 ) ) = 0.5
        _DisplaceIntensity ( "DisplacementIntensity" , Range( 0, 0.5 )) = 0
        _Gloss   ( "Gloss" , Range( 0, 1 ) ) = 0.5 
        
    }
    
    SubShader
    { 
        Tags { "RenderType"="Opaque" "Queue" = "Geometry" }  
              
        //Base pass
        Pass
        {
            Tags{ "LightMode" = "ForwardBase" }

            CGPROGRAM   
            #pragma vertex vert
            #pragma fragment frag
            #define IS_IN_BASE_PASS
            #include "CGLighting(10).cginc"
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
            #pragma multi_compile_fwdadd        //★多重編譯前向添加            
            #include "CGLighting(10).cginc"
            ENDCG
        }      
        
    }
}