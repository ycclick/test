Shader "Unlit/Test_TestMulti 8"
{
    Properties
    {
        _MainTex( "Texture" , 2D )          = "white" {}
        _Color  ( "Color" , Color )         = ( 1 , 1 , 1 , 1 )
        _Value  ( "Value" , float )         = 1.0
        _Gloss  ( "Gloss" , Range( 0, 1 ) ) = 0.5
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
            #include "CGLighting(8).cginc"
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
            #include "CGLighting(8).cginc"
            ENDCG
        }
        
    }
}
