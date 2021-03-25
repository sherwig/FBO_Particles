precision highp float;

uniform vec2 res;
uniform sampler2D lastFrame;
uniform sampler2D imgTex;
uniform sampler2D speedTex;
uniform sampler2D speedMap;
uniform float uTime;
uniform float rotAmp;
uniform float globalSpeed;
uniform float divider;
#define PI 3.1415926538

vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

     float snoise(vec2 v){
       const vec4 C = vec4(0.211324865405187, 0.366025403784439,
               -0.577350269189626, 0.024390243902439);
       vec2 i  = floor(v + dot(v, C.yy) );
       vec2 x0 = v -   i + dot(i, C.xx);
       vec2 i1;
       i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
       vec4 x12 = x0.xyxy + C.xxzz;
       x12.xy -= i1;
       i = mod(i, 289.0);
       vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
       + i.x + vec3(0.0, i1.x, 1.0 ));
       vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
         dot(x12.zw,x12.zw)), 0.0);
       m = m*m ;
       m = m*m ;
       vec3 x = 2.0 * fract(p * C.www) - 1.0;
       vec3 h = abs(x) - 0.5;
       vec3 ox = floor(x + 0.5);
       vec3 a0 = x - ox;
       m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
       vec3 g;
       g.x  = a0.x  * x0.x  + h.x  * x0.y;
       g.yz = a0.yz * x12.xz + h.yz * x12.yw;
       return 130.0 * dot(m, g);
     }

     // vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
     // vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
     // vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}
     //
     // float cnoise(vec3 P){
     //   vec3 Pi0 = floor(P); // Integer part for indexing
     //   vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
     //   Pi0 = mod(Pi0, 289.0);
     //   Pi1 = mod(Pi1, 289.0);
     //   vec3 Pf0 = fract(P); // Fractional part for interpolation
     //   vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
     //   vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
     //   vec4 iy = vec4(Pi0.yy, Pi1.yy);
     //   vec4 iz0 = Pi0.zzzz;
     //   vec4 iz1 = Pi1.zzzz;
     //
     //   vec4 ixy = permute(permute(ix) + iy);
     //   vec4 ixy0 = permute(ixy + iz0);
     //   vec4 ixy1 = permute(ixy + iz1);
     //
     //   vec4 gx0 = ixy0 / 7.0;
     //   vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
     //   gx0 = fract(gx0);
     //   vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
     //   vec4 sz0 = step(gz0, vec4(0.0));
     //   gx0 -= sz0 * (step(0.0, gx0) - 0.5);
     //   gy0 -= sz0 * (step(0.0, gy0) - 0.5);
     //
     //   vec4 gx1 = ixy1 / 7.0;
     //   vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
     //   gx1 = fract(gx1);
     //   vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
     //   vec4 sz1 = step(gz1, vec4(0.0));
     //   gx1 -= sz1 * (step(0.0, gx1) - 0.5);
     //   gy1 -= sz1 * (step(0.0, gy1) - 0.5);
     //
     //   vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
     //   vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
     //   vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
     //   vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
     //   vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
     //   vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
     //   vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
     //   vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);
     //
     //   vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
     //   g000 *= norm0.x;
     //   g010 *= norm0.y;
     //   g100 *= norm0.z;
     //   g110 *= norm0.w;
     //   vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
     //   g001 *= norm1.x;
     //   g011 *= norm1.y;
     //   g101 *= norm1.z;
     //   g111 *= norm1.w;
     //
     //   float n000 = dot(g000, Pf0);
     //   float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
     //   float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
     //   float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
     //   float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
     //   float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
     //   float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
     //   float n111 = dot(g111, Pf1);
     //
     //   vec3 fade_xyz = fade(Pf0);
     //   vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
     //   vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
     //   float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
     //   return 2.2 * n_xyz;
     // }

float random (vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233)))* 43758.5453123);
}

void main() {
  vec2 texel = 1. / res;
  // get orig color and normanlized numbers
  vec2 vUvOrig = gl_FragCoord.xy / res;
  vec4 imgColor = texture2D(imgTex, vUvOrig);
  // apply zoom & rotate displacement
  vec2 vUv = gl_FragCoord.xy / res;

  vec4 lastFrame = texture2D(lastFrame, vUv);
  // mix soomed with original
  // vec4 finalColor = mix(lastFrame, imgColor, mixOriginal);

  vec4 finalColor = lastFrame; // override mix with test pattern

  //instead of moving particles in a direction they should be turning

  //Getting out values out of our speed double buffer
  vec4 speedster = texture2D(speedMap, vUv);

  // finalColor.rgb += ((-0.5+speedster.rgb) / divider)*globalSpeed;
  //  float noiseZoom = 1.85;
  // float posX = finalColor.r;
  // float posY = finalColor.g;
  // float noiseOffset = snoise(vec2(uTime/10. + vUvOrig.x * 0.1, uTime/10. + vUvOrig.y * 0.1));
  // float noiseVal = snoise(vec2(noiseOffset + vUvOrig.x * 0.85 + posX * noiseZoom, noiseOffset + vUvOrig.y * 0.85 + posY * noiseZoom));
  //
  // finalColor.g += noiseVal;

  float noiseVal = snoise(vec2(vUvOrig.x+finalColor.x,vUvOrig.y+finalColor.y)*4.0+sin(uTime));

  // finalColor.r +=  noiseVal * 0.012;
  // finalColor.g +=  noiseVal * 0.008;

  finalColor.b += noiseVal *0.0016+sin(uTime*0.0008);

  finalColor.r =0.5;
  finalColor.g =0.5;


  if(finalColor.r > 1.) finalColor.r = 0.;
  if(finalColor.g > 1.) finalColor.g = 0.;
  if(finalColor.b > 1.) finalColor.b = 0.;
  if(finalColor.r < 0.) finalColor.r = 1.;
  if(finalColor.g < 0.) finalColor.g = 1.;
  if(finalColor.b < 0.) finalColor.b = 1.;

  // if(finalColor.r >= 1.) finalColor.r = 0.5;
  // if(finalColor.g >= 1.) finalColor.g = 0.5;
  // if(finalColor.b >= 1.) finalColor.b = 0.5;
  // if(finalColor.r <= 0.) finalColor.r = .5;
  // if(finalColor.g <= 0.) finalColor.g = .5;
  // if(finalColor.b <= 0.) finalColor.b = .5;

  float randomizer = random(vUvOrig);

  // finalColor.r =randomizer;
  // finalColor.g =randomizer;

  // finalColor.rgb = vec3(randomizer,randomizer,randomizer);

  // if(finalColor.r >= 1.) finalColor.r = randomizer;
  // if(finalColor.g >= 1.) finalColor.g = randomizer;
  // if(finalColor.b >= 1.) finalColor.b = randomizer;
  // if(finalColor.r <= 0.) finalColor.r = randomizer;
  // if(finalColor.g <= 0.) finalColor.g = randomizer;
  // if(finalColor.b <= 0.) finalColor.b = randomizer;

  // set final color
  gl_FragColor = finalColor;
}
