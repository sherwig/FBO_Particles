precision highp float;

uniform vec2 res;
uniform sampler2D lastFrame;
uniform sampler2D imgTex;
uniform sampler2D speedTex;
uniform float uTime;
uniform float mapDivider;
uniform float offsetSpeed;
uniform sampler2D positions;

#define PI 3.1415926538



vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permute(vec4 x) { return mod289(((x*34.0)+1.0)*x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }
float snoise(vec3 v) { const vec2 C = vec2(1.0/6.0, 1.0/3.0) ; const vec4 D = vec4(0.0, 0.5, 1.0, 2.0); vec3 i = floor(v + dot(v, C.yyy) ); vec3 x0 = v - i + dot(i, C.xxx) ; vec3 g = step(x0.yzx, x0.xyz); vec3 l = 1.0 - g; vec3 i1 = min( g.xyz, l.zxy ); vec3 i2 = max( g.xyz, l.zxy ); vec3 x1 = x0 - i1 + C.xxx; vec3 x2 = x0 - i2 + C.yyy; vec3 x3 = x0 - D.yyy; i = mod289(i); vec4 p = permute( permute( permute( i.z + vec4(0.0, i1.z, i2.z, 1.0 )) + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) + i.x + vec4(0.0, i1.x, i2.x, 1.0 )); float n_ = 0.142857142857; vec3 ns = n_ * D.wyz - D.xzx;vec4 j = p - 49.0 * floor(p * ns.z * ns.z); vec4 x_ = floor(j * ns.z); vec4 y_ = floor(j - 7.0 * x_ ); vec4 x = x_ *ns.x + ns.yyyy; vec4 y = y_ *ns.x + ns.yyyy; vec4 h = 1.0 - abs(x) - abs(y);vec4 b0 = vec4( x.xy, y.xy ); vec4 b1 = vec4( x.zw, y.zw );vec4 s0 = floor(b0)*2.0 + 1.0; vec4 s1 = floor(b1)*2.0 + 1.0; vec4 sh = -step(h, vec4(0.0));vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ; vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ; vec3 p0 = vec3(a0.xy,h.x); vec3 p1 = vec3(a0.zw,h.y); vec3 p2 = vec3(a1.xy,h.z); vec3 p3 = vec3(a1.zw,h.w);  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3))); p0 *= norm.x; p1 *= norm.y; p2 *= norm.z; p3 *= norm.w; vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0); m = m * m; return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3) ) ); }
vec3 snoiseVec3( vec3 x ){float s = snoise(vec3( x )); float s1 = snoise(vec3( x.y - 19.1 , x.z + 33.4 , x.x + 47.2 )); float s2 = snoise(vec3( x.z + 74.2 , x.x - 124.5 , x.y + 99.4 )); vec3 c = vec3( s , s1 , s2 ); return c;}
vec3 curlNoise( vec3 p ) { const float e = .1; vec3 dx = vec3( e , 0.0 , 0.0 ); vec3 dy = vec3( 0.0 , e , 0.0 ); vec3 dz = vec3( 0.0 , 0.0 , e ); vec3 p_x0 = snoiseVec3( p - dx ); vec3 p_x1 = snoiseVec3( p + dx ); vec3 p_y0 = snoiseVec3( p - dy ); vec3 p_y1 = snoiseVec3( p + dy ); vec3 p_z0 = snoiseVec3( p - dz ); vec3 p_z1 = snoiseVec3( p + dz ); float x = p_y1.z - p_y0.z - p_z1.y + p_z0.y; float y = p_z1.x - p_z0.x - p_x1.z + p_x0.z; float z = p_x1.y - p_x0.y - p_y1.x + p_y0.x; const float divisor = 1.0 / ( 2.0 * e ); return normalize( vec3( x , y , z ) * divisor ); }



// vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
// vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec3 P){
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod(Pi0, 289.0);
  Pi1 = mod(Pi1, 289.0);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 / 7.0;
  vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 / 7.0;
  vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
  return 2.2 * n_xyz;
}

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

  vec4 positionsMap = texture2D(positions, vUv);

  vec4 finalColor = lastFrame; // override mix with test pattern


  // float angle = atan(lastFrame.r,lastFrame.g);
  float angle = atan(vUvOrig.r*0.2,vUvOrig.g*0.2);

  // Find distance of everypoint from the center NEEDS WORK
  // float distanceToCenter = length(vUvOrig.rg);

  float distanceToCenter = distance(vUvOrig.rg, vec2(0.5));
  // float distanceToCenter = distance(lastFrame.rg, vec2(0.0));

  // float distanceToCenter= 0.5;

  // Increase the spin angle based on uTime and the distance from the center Closer to the center means it will go faster
  float angleOffset = (1.0/distanceToCenter)*uTime;
  angle+=angleOffset;
  // angle+=0.0001;
  lastFrame.r =0.5+0.5*cos(angle)*distanceToCenter;
  lastFrame.g =0.5+0.5*sin(angle)*distanceToCenter;

  vec2 displacedUV = vUvOrig + cnoise(vec3(vUvOrig.x*.02, vUvOrig.y*.02, uTime*0.1));
  // lastFrame.rg += displacedUV * 0.1;

  float randomizer = random(vUvOrig);
  lastFrame.rg += (randomizer * 0.2);
  finalColor.rg = lastFrame.rg;





  //VORTEX
  // float angle = atan(positionsMap.x,positionsMap.z);
  // // float distanceToCenter = length(positionsMap.xz);
  // float distanceToCenter = distance(positionsMap.xz+vUvOrig, vec2(0.5));
  //
  // float angleOffset = (1.0/distanceToCenter)*uTime;
  //
  // angle+=angleOffset*0.001;
  //
  // positionsMap.x = cos(angle)*distanceToCenter;
  // positionsMap.z = sin(angle)*distanceToCenter;
  //
  // finalColor.rgb = positionsMap.xyz;

  // positionsMap.x+=100.0;
  // positionsMap.y+=100.0;
  // positionsMap.z+=100.0;

  //PERLIN
  // vec2 displacedUV = vUvOrig + cnoise(vec3(vUvOrig.x*5.0, vUvOrig.y*5.0, uTime*0.1));
  // float strength = cnoise(vec3(displacedUV.x*5.0, displacedUV.y*5.0, uTime*0.2));
  // float outerGlow = 1.0-distance(vUvOrig, vec2(0.5)) * 5.0 ;
  // strength+=outerGlow;
  // finalColor.rgb = vec3(strength);

  // CURL NOISE
  // vec3 placeholder = vec3(0.5,0.5,0.5);
  // vec3 curlInput = positionsMap.xyz / mapDivider + vec3(1. - vUvOrig.r, 1. - vUvOrig.g, 1. - vUvOrig.r)+sin(uTime*offsetSpeed);
  // vec3 curlResult = curlNoise(curlInput);
  // finalColor.rgb = curlResult*0.5;


  if(finalColor.r > 1.) finalColor.r = 0.;
  if(finalColor.g > 1.) finalColor.g = 0.;
  if(finalColor.b > 1.) finalColor.b = 0.;
  if(finalColor.r < 0.) finalColor.r = 1.;
  if(finalColor.g < 0.) finalColor.g = 1.;
  if(finalColor.b < 0.) finalColor.b = 1.;
  // set final color


  gl_FragColor = finalColor;
}
