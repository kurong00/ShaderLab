// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Rim/RimLightingFix" {
	Properties{
		_MainColor("Main Color", Color) = (1,1,1,1)
		_OutlineCol("OutlineCol", Color) = (1,0,0,1)
		_OutlineFactor("OutlineFactor", Range(0,1)) = 0.1
		_MainTex("Base 2D", 2D) = "white"{}
		_Factor("Control Factor",Range(0,1)) = 0.1 
	}
	SubShader
	{
		//描边使用两个Pass，第一个pass沿法线挤出一点，只输出描边的颜色
		Pass{
		Cull Front
		CGPROGRAM
		#include "UnityCG.cginc"
		//使用vert函数和frag函数
		#pragma vertex vert
		#pragma fragment frag
		fixed4 _OutlineCol;
		float _OutlineFactor;
		float _Factor;	
		struct v2f
		{
			float4 pos : SV_POSITION;
		};

		v2f vert(appdata_full v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos ( v.vertex );
			float3 vnormal1 = normalize ( v.vertex.xyz );
			//将法线方向转换到视空间
			float3 vnormal2 = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
			vnormal1 = lerp ( vnormal1, vnormal2, _Factor );
			vnormal1 = mul ( ( float3x3 ) UNITY_MATRIX_IT_MV, vnormal1);
			float2 offset = TransformViewToProjection (vnormal1.xy );
			offset = normalize ( offset );
			float dist = distance ( mul ( UNITY_MATRIX_M, v.vertex ), _WorldSpaceCameraPos );
			o.pos.xy += offset *_OutlineFactor;
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			//这个Pass直接输出描边颜色
			return _OutlineCol;
		}
		ENDCG
		}

		//正常着色的Pass
		Pass
		{
			CGPROGRAM
			//引入头文件
			#include "Lighting.cginc"
			//使用vert函数和frag函数
			#pragma vertex vert
			#pragma fragment frag	
			//定义Properties中的变量
			fixed4 _MainColor;
			sampler2D _MainTex;
			//定义结构体：vertex shader阶段输出的内容
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
			};
			//定义顶点shader,参数直接使用appdata_base（包含position, noramal, texcoord）
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				//通过TRANSFORM_TEX宏转化纹理坐标，主要处理了Offset和Tiling的改变
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				return o;
			}

			//定义片元shader
			fixed4 frag(v2f i) : SV_Target
			{
				//unity自身的diffuse也是带了环境光，这里我们也增加一下环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _MainColor.xyz;
				//归一化法线，即使在vert归一化也不行，从vert到frag阶段有差值处理，传入的法线方向并不是vertex shader直接传出的
				fixed3 worldNormal = normalize(i.worldNormal);
				//把光照方向归一化
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				//根据半兰伯特模型计算像素的光照信息
				fixed3 lambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
				//最终输出颜色为lambert光强*材质diffuse颜色*光颜色
				fixed3 diffuse = lambert * _MainColor.xyz * _LightColor0.xyz + ambient;
				//进行纹理采样
				fixed4 color = _MainColor;
				color.rgb = color.rgb* diffuse;
				return fixed4(color);
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}