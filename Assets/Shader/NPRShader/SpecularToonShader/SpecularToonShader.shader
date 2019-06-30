Shader "Kurong/NPR/SpecularToonShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [HDR]_AmbientColor("Ambient Color", Color) = (1,1,1,1)
        [HDR]_SpecularColor("Specular Color", Color) = (1,1,1,1)
        _Glossiness("Glossiness", Float) = 32
        [HDR]_RimColor("Rim Color", Color) = (1,1,1,1)
        _RimAmount("Rim Amount", Range(0, 1)) = 0.5
        _RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" "PassFlags" = "OnlyDirectional" }
            LOD 200
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "AutoLight.cginc"
            #include "UnityCG.cginc" 
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _Color;
            float4 _MainTex_ST;
            float4 _AmbientColor;
            float4 _SpecularColor;
            float _Glossiness;
            float4 _RimColor;
            float _RimAmount;
            float _RimThreshold;

            struct a2f
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
			{
				float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 viewDir : TEXCOORD1;
                SHADOW_COORDS(2)
			};

            v2f vert (a2f v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                TRANSFER_SHADOW(o)
                return o;
            }

            float4 frag (v2f v) : SV_Target
            {
                float3 normal = normalize(v.worldNormal);
                float NdotL = dot(_WorldSpaceLightPos0 , normal);
                float shadow = SHADOW_ATTENUATION(v);
                float lightIntensity = smoothstep(0, 0.01, NdotL * shadow);
                float4 light = lightIntensity * _LightColor0;
                float3 viewDir = normalize(v.viewDir);
                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                float NdotH = dot(normal, halfVector);
                float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);
                float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
                float4 specular = specularIntensitySmooth * _SpecularColor;
                float4 rimDot = 1 - dot(viewDir, normal);
                float rimIntensity = rimDot * pow(NdotL, _RimThreshold);;
                rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
                float4 rim = rimIntensity * _RimColor;
                return _Color * (light + _AmbientColor + specular + rim);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
