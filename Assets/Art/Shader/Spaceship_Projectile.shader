// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Spaceship_Projectile"
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
				float2 texCoord17 = v.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 panner18 = ( 1.0 * _Time.y * temp_cast_0 + texCoord17);
				
				float3 ase_normalWS = UnityObjectToWorldNormal( v.ase_normal );
				o.ase_texcoord1.xyz = ase_normalWS;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = ( tex2Dlod( _Tex_Fresnel, float4( panner18, 0, 0.0) ).r * v.ase_normal * _Fresnel_Intensity );
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
				float fresnelNdotV7 = dot( ase_normalWS, ase_viewDirWS );
				float fresnelNode7 = ( _F_Bias1 + _F_Scale1 * pow( max( 1.0 - fresnelNdotV7 , 0.0001 ), _F_Power1 ) );
				float clampResult8 = clamp( fresnelNode7 , 0.0 , 10.0 );
				float4 appendResult14 = (float4(( ( clampResult8 * ( _Color.rgb * _F_HDR ) ) + float3( 0,0,0 ) ) , clampResult8));
				

				finalColor = appendResult14;
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
Node;AmplifyShaderEditor.CommentaryNode;1;-2656,-400;Inherit;False;1253.283;495.6732;;7;13;12;8;7;4;3;2;Fresnel;0.7783019,0.9759024,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-2608,-320;Inherit;False;Property;_F_Bias1;F_Bias;2;0;Create;True;0;0;0;False;0;False;-0.07;0.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-2608,-80;Inherit;False;Property;_F_Power1;F_Power;0;0;Create;True;0;0;0;False;0;False;2.98;1.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-2592,-208;Inherit;False;Property;_F_Scale1;F_Scale;1;0;Create;True;0;0;0;False;0;False;3.49;3.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;5;-1360,-288;Inherit;False;Property;_Color;Color;4;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.5903842,1,0.3999999,1;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;6;-1200,-32;Inherit;False;Property;_F_HDR;F_HDR;3;0;Create;True;0;0;0;False;0;False;3.9;4.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;7;-2336,-272;Inherit;True;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;8;-1872,-352;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1088,-256;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1232,640;Inherit;False;Property;_Fresnel_Speed;Fresnel_Speed;7;0;Create;True;0;0;0;False;0;False;1;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;17;-1376,288;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-912,-480;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;18;-1088,336;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,-0.49;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-672,-96;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-752,672;Inherit;False;Property;_Fresnel_Intensity;Fresnel_Intensity;6;0;Create;True;0;0;0;False;0;False;0.257272;0.7308466;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;19;-720,400;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;20;-896,176;Inherit;True;Property;_Tex_Fresnel;Tex_Fresnel;5;0;Create;True;0;0;0;False;0;False;-1;f1d51ed493a42ad4789ff2be401e8b43;f1d51ed493a42ad4789ff2be401e8b43;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.OneMinusNode;12;-2000,-128;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;13;-1600,-144;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;14;-320,64;Inherit;False;COLOR;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-384,384;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;True;-1;3;AmplifyShaderEditor.MaterialInspector;100;5;Spaceship_Projectile;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;7;1;2;0
WireConnection;7;2;4;0
WireConnection;7;3;3;0
WireConnection;8;0;7;0
WireConnection;9;0;5;5
WireConnection;9;1;6;0
WireConnection;10;0;8;0
WireConnection;10;1;9;0
WireConnection;18;0;17;0
WireConnection;18;2;15;0
WireConnection;11;0;10;0
WireConnection;20;1;18;0
WireConnection;12;0;7;0
WireConnection;13;0;12;0
WireConnection;14;0;11;0
WireConnection;14;3;8;0
WireConnection;21;0;20;1
WireConnection;21;1;19;0
WireConnection;21;2;16;0
WireConnection;0;0;14;0
WireConnection;0;1;21;0
ASEEND*/
//CHKSM=32011C65BA100C845499457343F3895B6A3E5B53