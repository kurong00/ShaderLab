Shader "Kurong/NPR/Sketch"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _TileFactor ("Tile Factor", Float) = 5
        _Hatch0 ("_Hatch0", 2D) = "white" {}
        _Hatch1 ("_Hatch1", 2D) = "white" {}
        _Hatch2 ("_Hatch2", 2D) = "white" {}
        _Hatch3 ("_Hatch3", 2D) = "white" {}
        _Hatch4 ("_Hatch4", 2D) = "white" {}
        _Hatch5 ("_Hatch5", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "LightMode" = "ForwardBase" }
        LOD 200
        Pass
		{
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"

            fixed4 _Color;
            float _TileFactor;
            sampler2D _Hatch0;
            sampler2D _Hatch1;
            sampler2D _Hatch2;
            sampler2D _Hatch3;
            sampler2D _Hatch4;
            sampler2D _Hatch5;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
            }; 

            struct v2f{
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed3 hatchWeight1 : TEXCOORD1;
                fixed3 hatchWeight2 : TEXCOORD2;
                float3 worldPos : TEXCOORD3;
                SHADOW_COORDS(4)
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _TileFactor;
                fixed3 worldLight = normalize(WorldSpaceLightDir(v.vertex));
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 diff = max(0,dot(worldLight,worldNormal));
                o.hatchWeight1 = fixed3(0,0,0);
                o.hatchWeight2 = fixed3(0,0,0);
                float hatchFactor = diff * 7.0;
                //if (hatchFactor > 6.0) {}
                if(hatchFactor > 5.0) 
                    o.hatchWeight1.x = hatchFactor - 5.0;
                else if(hatchFactor > 4.0) {
                    o.hatchWeight1.x = hatchFactor - 4.0;
                    o.hatchWeight1.y = 1.0 - o.hatchWeight1.x;
                }
                else if(hatchFactor > 3.0) {
                    o.hatchWeight1.y = hatchFactor - 3.0;
                    o.hatchWeight1.z = 1.0 - o.hatchWeight1.y;
                }
                else if(hatchFactor > 2.0) {
                    o.hatchWeight1.z = hatchFactor - 2.0;
                    o.hatchWeight2.x = 1.0 - o.hatchWeight1.z;
                }
                else if(hatchFactor > 1.0) {
                    o.hatchWeight2.x = hatchFactor - 1.0;
                    o.hatchWeight2.y = 1.0 - o.hatchWeight2.x;
                }
                else{
                    o.hatchWeight2.y = hatchFactor;
                    o.hatchWeight2.z = 1.0 - o.hatchWeight2.y;
                }
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                fixed4 hatchText0 = tex2D(_Hatch0,i.uv)*i.hatchWeight1.x;
                fixed4 hatchText1 = tex2D(_Hatch1,i.uv)*i.hatchWeight1.y;
                fixed4 hatchText2 = tex2D(_Hatch2,i.uv)*i.hatchWeight1.z;
                fixed4 hatchText3 = tex2D(_Hatch3,i.uv)*i.hatchWeight2.x;
                fixed4 hatchText4 = tex2D(_Hatch4,i.uv)*i.hatchWeight2.y;
                fixed4 hatchText5 = tex2D(_Hatch5,i.uv)*i.hatchWeight2.z;
                fixed4 whiteColor = fixed4(1,1,1,1)*(1-i.hatchWeight1.x-i.hatchWeight1.y-i.hatchWeight1.z
                -i.hatchWeight2.x-i.hatchWeight2.y-i.hatchWeight2.z);
                fixed4 hatchColor = hatchText0 + hatchText1 + hatchText2 + hatchText3 + hatchText4 + hatchText5 + whiteColor;
                return fixed4(hatchColor.rgb * _Color.rgb, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
