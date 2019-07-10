Shader "Kurong/NPR/Outline"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineRange ("Outline Range", Range(0,0.5)) = 0.1
		_OutlineColor("Outline Color", Color) = (1,1,1,1)
    }
    SubShader
    {
		Pass
        {
            Tags { "RenderType"="Opaque" }
            LOD 200
            ZWrite Off

            CGPROGRAM

            #pragma vertex vert

            #pragma fragment frag

            #include "UnityCG.cginc"

            float _OutlineRange;
            float4 _OutlineColor;

            struct a2v
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (a2v v)
            {
                v.vertex.xyz += _OutlineRange * normalize(v.vertex.xyz);
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f v) : Color
            {
                return _OutlineColor;
            }
            ENDCG
        }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        
        sampler2D _MainTex;
        fixed4 _Color;
        
        struct Input 
        {
            float2 uv_MainTex;
        };
            
        void surf (Input IN, inout SurfaceOutputStandard o) 
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
