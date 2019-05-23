Shader "Kurong/NPR/SpecularToonShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            LOD 200
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc" 
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _Color;
            float4 _MainTex_ST;

            struct a2f
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
            };

            v2f vert (a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag (v2f v) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
