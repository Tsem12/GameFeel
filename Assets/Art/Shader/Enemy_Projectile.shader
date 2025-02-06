// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Enemy_Projectile"
{
	Properties
	{
		_F_Power1("F_Power", Float) = 2.98
		_F_Scale1("F_Scale", Float) = 3.49
		_F_Bias1("F_Bias", Float) = -0.07
		_F_HDR("F_HDR", Float) = 3.9
		_Color("Color", Color) = (1,1,1,1)
		_Tex_Fresnel("Tex_Fresnel", 2D) = "white" {}
		_Fresnel_Intensity("Fresnel_Intensity", Range( 0 , 1)) = 0.257272
		_Fresnel_Speed("Fresnel_Speed", Float) = 1

	}

	SubShader
	{
		

		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		

		
		Pass
		{
			Name "Unlit"

			CGPROGRAM

			#define ASE_VERSION 19801


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _Tex_Fresnel;
			uniform float _Fresnel_Speed;
			uniform float _Fresnel_Intensity;
			uniform float _F_Bias1;
			uniform float _F_Scale1;
			uniform float _F_Power1;
			uniform float4 _Color;
			uniform float _F_HDR;


			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float2 temp_cast_0 = (_Fresnel_Speed).xx;
				float2 texCoord81 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner80 = ( 1.0 * _Time.y * temp_cast_0 + texCoord81);
				
				float3 ase_normalWS = UnityObjectToWorldNormal( v.ase_normal );
				o.ase_texcoord1.xyz = ase_normalWS;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = ( tex2Dlod( _Tex_Fresnel, float4( panner80, 0, 0.0) ).r * v.ase_normal * _Fresnel_Intensity );
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}

			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_viewVectorWS = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				float3 ase_viewDirWS = normalize( ase_viewVectorWS );
				float3 ase_normalWS = i.ase_texcoord1.xyz;
				float fresnelNdotV16 = dot( ase_normalWS, ase_viewDirWS );
				float fresnelNode16 = ( _F_Bias1 + _F_Scale1 * pow( max( 1.0 - fresnelNdotV16 , 0.0001 ), _F_Power1 ) );
				float clampResult20 = clamp( fresnelNode16 , 0.0 , 10.0 );
				float4 appendResult43 = (float4(( ( clampResult20 * ( _Color.rgb * _F_HDR ) ) + float3( 0,0,0 ) ) , clampResult20));
				

				finalColor = appendResult43;
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.CommentaryNode;10;-2528,-368;Inherit;False;1253.283;495.6732;;7;20;18;17;16;15;14;13;Fresnel;0.7783019,0.9759024,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2480,-288;Inherit;False;Property;_F_Bias1;F_Bias;3;0;Create;True;0;0;0;False;0;False;-0.07;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-2480,-48;Inherit;False;Property;_F_Power1;F_Power;1;0;Create;True;0;0;0;False;0;False;2.98;2.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-2464,-176;Inherit;False;Property;_F_Scale1;F_Scale;2;0;Create;True;0;0;0;False;0;False;3.49;7.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;26;-1232,-256;Inherit;False;Property;_Color;Color;5;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;27;-1072,0;Inherit;False;Property;_F_HDR;F_HDR;4;0;Create;True;0;0;0;False;0;False;3.9;3.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;16;-2208,-240;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;20;-1744,-320;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-960,-224;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;81;-992,896;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-880,1248;Inherit;False;Property;_Fresnel_Speed;Fresnel_Speed;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-784,-448;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;80;-784,960;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.49;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;11;-4080,80;Inherit;False;1322.123;782.1943;Comment;6;19;28;25;83;84;85;Texture;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;12;-2578,256;Inherit;False;1217.223;706.4607;Comment;12;40;39;38;37;36;35;34;33;32;31;30;29;Color Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalVertexDataNode;77;-368,1008;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;79;-544,784;Inherit;True;Property;_Tex_Fresnel;Tex_Fresnel;7;0;Create;True;0;0;0;False;0;False;-1;f1d51ed493a42ad4789ff2be401e8b43;f1d51ed493a42ad4789ff2be401e8b43;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;78;-400,1280;Inherit;False;Property;_Fresnel_Intensity;Fresnel_Intensity;8;0;Create;True;0;0;0;False;0;False;0.257272;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-544,-64;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;17;-1872,-96;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;83;-3968,240;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,2;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;18;-1472,-112;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;84;-3666,336;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.12,0.12;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;28;-3442,240;Inherit;True;Property;_Tex_Enemy_Projectile;Tex_Enemy_Projectile;0;0;Create;True;0;0;0;False;0;False;-1;75b254a55f7e3f347ac8f2b5db9b11d9;0f0e0708166913e448eb6195f7e96bdd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;85;-3362,560;Inherit;False;Constant;_Min_Smoothstep;Min_Smoothstep;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-3346,688;Inherit;False;Constant;_Max_Smoothstep;Max_Smoothstep;8;0;Create;True;0;0;0;False;0;False;0.81;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;19;-3026,400;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;3.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientSampleNode;29;-2546,400;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RGBToHSVNode;30;-2290,608;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;36;-2210,464;Inherit;False;Constant;_Hue;Hue;27;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-2466,736;Inherit;False;Constant;_saturation;saturation;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-2290,832;Inherit;False;Constant;_value;value;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-2034,624;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-2034,768;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-2002,480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;39;-1826,608;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;40;-1602,672;Inherit;False;Property;_Tex_HDR;Tex_HDR;6;0;Create;True;0;0;0;False;0;False;1.93;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-1570,368;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GradientNode;35;-2754,320;Inherit;False;1;3;2;1,0,0.07128334,0.3794156;0.245283,0.129655,0.1258811,0.8147097;1,0.2667904,0,1;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-16,992;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1376,208;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;43;-192,96;Inherit;False;COLOR;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;42;144,288;Float;False;True;-1;3;AmplifyShaderEditor.MaterialInspector;100;5;Enemy_Projectile;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;16;1;13;0
WireConnection;16;2;14;0
WireConnection;16;3;15;0
WireConnection;20;0;16;0
WireConnection;23;0;26;5
WireConnection;23;1;27;0
WireConnection;22;0;20;0
WireConnection;22;1;23;0
WireConnection;80;0;81;0
WireConnection;80;2;82;0
WireConnection;79;1;80;0
WireConnection;41;0;22;0
WireConnection;17;0;16;0
WireConnection;18;0;17;0
WireConnection;84;0;83;0
WireConnection;28;1;84;0
WireConnection;19;0;28;1
WireConnection;19;1;85;0
WireConnection;19;2;25;0
WireConnection;29;0;35;0
WireConnection;29;1;19;0
WireConnection;30;0;29;0
WireConnection;31;0;30;2
WireConnection;31;1;37;0
WireConnection;32;0;30;3
WireConnection;32;1;38;0
WireConnection;34;0;30;1
WireConnection;34;1;36;0
WireConnection;39;0;34;0
WireConnection;39;1;31;0
WireConnection;39;2;32;0
WireConnection;33;0;39;0
WireConnection;33;1;40;0
WireConnection;76;0;79;1
WireConnection;76;1;77;0
WireConnection;76;2;78;0
WireConnection;43;0;41;0
WireConnection;43;3;20;0
WireConnection;42;0;43;0
WireConnection;42;1;76;0
ASEEND*/
//CHKSM=7779E0141A9EA29D086328A83EE1D845BBFF8CB9