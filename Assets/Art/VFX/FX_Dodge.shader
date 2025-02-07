// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "FX_Dodge"
{
	Properties
	{
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex ("Particle Texture", 2D) = "white" {}
		_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
		_Texture("Texture", 2D) = "white" {}
		_Text_pouet("Text_pouet", 2D) = "white" {}
		_HDR("HDR", Float) = 0
		_L_Min("L_Min", Float) = 0
		_L_MAX("L_MAX", Float) = 0
		_D_Tile_X("D_Tile_X", Float) = 0
		_D_Tile_Y("D_Tile_Y", Float) = 0
		_D_Speed_Y("D_Speed_Y", Float) = 0
		_D_Speed_X("D_Speed_X", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}


	Category
	{
		SubShader
		{
		LOD 0

			Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB
			Cull Off
			Lighting Off
			ZWrite Off
			ZTest LEqual
			
			Pass {

				CGPROGRAM
				#define ASE_VERSION 19801

				#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
				#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
				#endif

				#pragma vertex vert
				#pragma fragment frag
				#pragma target 3.5
				#pragma multi_compile_instancing
				#pragma multi_compile_particles
				#pragma multi_compile_fog
				#include "UnityShaderVariables.cginc"
				#define ASE_NEEDS_FRAG_COLOR


				#include "UnityCG.cginc"

				struct appdata_t
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float4 texcoord : TEXCOORD0;
					UNITY_FOG_COORDS(1)
					#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD2;
					#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
					
				};


				#if UNITY_VERSION >= 560
				UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
				#else
				uniform sampler2D_float _CameraDepthTexture;
				#endif

				//Don't delete this comment
				// uniform sampler2D_float _CameraDepthTexture;

				uniform sampler2D _MainTex;
				uniform fixed4 _TintColor;
				uniform float4 _MainTex_ST;
				uniform float _InvFade;
				uniform float _HDR;
				uniform float _L_Min;
				uniform float _L_MAX;
				uniform sampler2D _Text_pouet;
				uniform float _D_Speed_X;
				uniform float _D_Speed_Y;
				uniform float _D_Tile_X;
				uniform float _D_Tile_Y;
				uniform sampler2D _Texture;
				uniform float4 _Texture_ST;
				struct Gradient
				{
					int type;
					int colorsLength;
					int alphasLength;
					float4 colors[8];
					float2 alphas[8];
				};
				
				Gradient NewGradient(int type, int colorsLength, int alphasLength, 
				float4 colors0, float4 colors1, float4 colors2, float4 colors3, float4 colors4, float4 colors5, float4 colors6, float4 colors7,
				float2 alphas0, float2 alphas1, float2 alphas2, float2 alphas3, float2 alphas4, float2 alphas5, float2 alphas6, float2 alphas7)
				{
					Gradient g;
					g.type = type;
					g.colorsLength = colorsLength;
					g.alphasLength = alphasLength;
					g.colors[ 0 ] = colors0;
					g.colors[ 1 ] = colors1;
					g.colors[ 2 ] = colors2;
					g.colors[ 3 ] = colors3;
					g.colors[ 4 ] = colors4;
					g.colors[ 5 ] = colors5;
					g.colors[ 6 ] = colors6;
					g.colors[ 7 ] = colors7;
					g.alphas[ 0 ] = alphas0;
					g.alphas[ 1 ] = alphas1;
					g.alphas[ 2 ] = alphas2;
					g.alphas[ 3 ] = alphas3;
					g.alphas[ 4 ] = alphas4;
					g.alphas[ 5 ] = alphas5;
					g.alphas[ 6 ] = alphas6;
					g.alphas[ 7 ] = alphas7;
					return g;
				}
				
				float4 SampleGradient( Gradient gradient, float time )
				{
					float3 color = gradient.colors[0].rgb;
					UNITY_UNROLL
					for (int c = 1; c < 8; c++)
					{
					float colorPos = saturate((time - gradient.colors[c-1].w) / ( 0.00001 + (gradient.colors[c].w - gradient.colors[c-1].w)) * step(c, (float)gradient.colorsLength-1));
					color = lerp(color, gradient.colors[c].rgb, lerp(colorPos, step(0.01, colorPos), gradient.type));
					}
					#ifndef UNITY_COLORSPACE_GAMMA
					color = half3(GammaToLinearSpaceExact(color.r), GammaToLinearSpaceExact(color.g), GammaToLinearSpaceExact(color.b));
					#endif
					float alpha = gradient.alphas[0].x;
					UNITY_UNROLL
					for (int a = 1; a < 8; a++)
					{
					float alphaPos = saturate((time - gradient.alphas[a-1].y) / ( 0.00001 + (gradient.alphas[a].y - gradient.alphas[a-1].y)) * step(a, (float)gradient.alphasLength-1));
					alpha = lerp(alpha, gradient.alphas[a].x, lerp(alphaPos, step(0.01, alphaPos), gradient.type));
					}
					return float4(color, alpha);
				}
				


				v2f vert ( appdata_t v  )
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					

					v.vertex.xyz +=  float3( 0, 0, 0 ) ;
					o.vertex = UnityObjectToClipPos(v.vertex);
					#ifdef SOFTPARTICLES_ON
						o.projPos = ComputeScreenPos (o.vertex);
						COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color;
					o.texcoord = v.texcoord;
					UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				fixed4 frag ( v2f i  ) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID( i );
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( i );

					#ifdef SOFTPARTICLES_ON
						float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
						float partZ = i.projPos.z;
						float fade = saturate (_InvFade * (sceneZ-partZ));
						i.color.a *= fade;
					#endif

					Gradient gradient62 = NewGradient( 0, 2, 2, float4( 1, 1, 1, 0 ), float4( 0, 0.6136239, 1, 0.997055 ), 0, 0, 0, 0, 0, 0, float2( 1, 0 ), float2( 1, 1 ), 0, 0, 0, 0, 0, 0 );
					float2 appendResult75 = (float2(_D_Speed_X , _D_Speed_Y));
					float2 texCoord69 = i.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
					float2 appendResult70 = (float2(_D_Tile_X , _D_Tile_Y));
					float2 panner67 = ( 1.0 * _Time.y * appendResult75 + (texCoord69*appendResult70 + 0.0));
					float smoothstepResult63 = smoothstep( _L_Min , _L_MAX , tex2D( _Text_pouet, panner67 ).r);
					float2 uv_Texture = i.texcoord.xy * _Texture_ST.xy + _Texture_ST.zw;
					float4 temp_output_76_0 = ( SampleGradient( gradient62, smoothstepResult63 ) * ( tex2D( _Texture, uv_Texture ) * i.color ) );
					float4 appendResult19 = (float4(( _HDR * (temp_output_76_0).rgb ) , (temp_output_76_0).a));
					

					fixed4 col = appendResult19;
					UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDCG
			}
		}
	}
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.RangedFloatNode;71;-2144,48;Inherit;False;Property;_D_Tile_X;D_Tile_X;5;0;Create;True;0;0;0;False;0;False;0;0.47;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-2114.288,168.6944;Inherit;False;Property;_D_Tile_Y;D_Tile_Y;6;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;69;-1952,-128;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;70;-1904,48;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-1776,160;Inherit;False;Property;_D_Speed_X;D_Speed_X;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1776,272;Inherit;False;Property;_D_Speed_Y;D_Speed_Y;7;0;Create;True;0;0;0;False;0;False;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;68;-1680,-80;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;1,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;75;-1568,208;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;67;-1376,-32;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;64;-1184,-96;Inherit;True;Property;_Text_pouet;Text_pouet;1;0;Create;True;0;0;0;False;0;False;-1;None;6415e4b059f8ca249ad6c1c205f2330e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;65;-1024,128;Inherit;False;Property;_L_Min;L_Min;3;0;Create;True;0;0;0;False;0;False;0;2.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-976,240;Inherit;False;Property;_L_MAX;L_MAX;4;0;Create;True;0;0;0;False;0;False;0;-0.23;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;12;-896,640;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;13;-976,368;Inherit;True;Property;_Texture;Texture;0;0;Create;True;0;0;0;False;0;False;-1;None;2102b7016c7576942869381de5001e10;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SmoothstepOpNode;63;-704,-16;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GradientNode;62;-608,-176;Inherit;False;0;2;2;1,1,1,0;0,0.6136239,1,0.997055;1,0;1,1;0;1;OBJECT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-672,576;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GradientSampleNode;61;-336,-48;Inherit;True;2;0;OBJECT;;False;1;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;16,224;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;16;288,160;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;15;368,-64;Inherit;False;Property;_HDR;HDR;2;0;Create;True;0;0;0;False;0;False;0;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;576,192;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;18;288,400;Inherit;False;False;False;False;True;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;19;720,304;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;20;960,208;Float;False;True;-1;3;AmplifyShaderEditor.MaterialInspector;0;11;FX_Dodge;0b6a9f8b4f707c74ca64c0be8e590de0;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;False;True;2;5;False;;10;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;True;True;True;True;False;0;False;;False;False;False;False;False;False;False;False;False;True;2;False;;True;3;False;;False;True;4;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;70;0;71;0
WireConnection;70;1;72;0
WireConnection;68;0;69;0
WireConnection;68;1;70;0
WireConnection;75;0;74;0
WireConnection;75;1;73;0
WireConnection;67;0;68;0
WireConnection;67;2;75;0
WireConnection;64;1;67;0
WireConnection;63;0;64;1
WireConnection;63;1;65;0
WireConnection;63;2;66;0
WireConnection;14;0;13;0
WireConnection;14;1;12;0
WireConnection;61;0;62;0
WireConnection;61;1;63;0
WireConnection;76;0;61;0
WireConnection;76;1;14;0
WireConnection;16;0;76;0
WireConnection;17;0;15;0
WireConnection;17;1;16;0
WireConnection;18;0;76;0
WireConnection;19;0;17;0
WireConnection;19;3;18;0
WireConnection;20;0;19;0
ASEEND*/
//CHKSM=08B2E3AE7016649AB41AE34353604ED8A420FDBC