Shader "Kurong/NPR/ToonShaer"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        [HDR]_AmbientColor("Ambient Color", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        [HDR]_SpecularColor("Specular Color", Color) = (1,1,1,1)
        _Glossiness("Glossiness", Float) = 32
        [HDR]_RimColor("Rim Color", Color) = (1,1,1,1)
        _RimAmount("Rim Amount", Range(0, 1)) = 0.716
        _RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" "PassFlags" = "OnlyDirectional" }
        LOD 200
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
            float4 _AmbientColor;
            float _Glossiness;
            float4 _SpecularColor;
            float4 _RimColor;
            float _RimAmount;
            float _RimThreshold;

            struct a2f
			{
				float4 vertex : POSITION;				
				float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
                float3 worldNormal : NORMAL;
                float3 viewDir : TEXCOORD1;
			};
			
			v2f vert (a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                return o;
            }

			float4 frag (v2f v) : SV_Target
            {
                float3 normal = normalize(v.worldNormal);
                float dotL = dot(normal,_WorldSpaceLightPos0);
                float lightIntensity = smoothstep(0, 0.01, dotL);;
                float4 light = lightIntensity * _LightColor0;
                float3 viewDir = normalize(v.viewDir);
                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                float dotH = dot(normal, halfVector);
                float specularIntensity = pow(dotH * lightIntensity, _Glossiness * _Glossiness);
                float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
                float4 specular = specularIntensitySmooth * _SpecularColor;
                float4 rimDot = 1 - dot(viewDir, normal);
                float rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimDot);
                float4 rim = rimIntensity * _RimColor;
                float4 sample = tex2D(_MainTex, v.uv);
                return _Color * (_AmbientColor + light + specular + rim);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
