
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AvatarPreview extends StatelessWidget {
  final String gender, height, body, skin, hair, hairColor;
  final String makeup, top, bottom, shoes, accessory, clothingColor;

  const AvatarPreview({
    super.key,
    this.gender = 'Female',
    this.height = 'Medium',
    this.body = 'Medium',
    this.skin = '#E8B894',
    this.hair = 'Long',
    this.hairColor = '#39251D',
    this.makeup = 'None',
    this.top = 'T-shirt',
    this.bottom = 'Jeans',
    this.shoes = 'Sneakers',
    this.accessory = 'None',
    this.clothingColor = '#8B5CF6',
  });

  @override
  Widget build(BuildContext context) {
    final width = ({
      'Slim': 30.0,
      'Medium': 38.0,
      'Broad': 46.0,
      'Full': 54.0,
    }[body] ?? 38.0) + (gender == 'Male' ? 5 : 0);

    final scale = {
      'Short': 0.85,
      'Medium': 1.0,
      'Tall': 1.12,
    }[height] ?? 1.0;

    final pantsColor = bottom == 'Jeans'
        ? '#42658C'
        : bottom == 'Shorts'
            ? '#C4A484'
            : '#374151';

    final shoeColor = shoes == 'Sneakers'
        ? '#FFFFFF'
        : '#45352E';

    final svg = '''
    <svg xmlns="http://www.w3.org/2000/svg"
         viewBox="0 0 240 360">
      <ellipse cx="120" cy="338" rx="65" ry="8"
               fill="#D8C9EA"/>

      <g transform="translate(120 330) scale(1 $scale)
                    translate(0 -300)">

        <!-- Hair behind head -->
        ${hair == 'Long' || hair == 'Braids' ? '''
        <rect x="-39" y="14" width="78" height="130"
              rx="32" fill="$hairColor"/>
        ''' : ''}

        <!-- Legs -->
        <rect x="-29" y="195" width="25" height="95"
              rx="10" fill="$skin"/>
        <rect x="4" y="195" width="25" height="95"
              rx="10" fill="$skin"/>

        <!-- Bottom clothing -->
        ${bottom == 'Skirt' ? '''
        <path d="M -$width 178 L $width 178
                 L 52 237 L -52 237 Z"
              fill="$pantsColor"/>
        ''' : '''
        <rect x="-32" y="183" width="29"
              height="${bottom == 'Shorts' ? 48 : 103}"
              rx="8" fill="$pantsColor"/>
        <rect x="3" y="183" width="29"
              height="${bottom == 'Shorts' ? 48 : 103}"
              rx="8" fill="$pantsColor"/>
        '''}

        <!-- Shoes -->
        <rect x="-35" y="${shoes == 'Boots' ? 267 : 285}"
              width="35" height="${shoes == 'Boots' ? 33 : 15}"
              rx="7" fill="$shoeColor"/>
        <rect x="0" y="${shoes == 'Boots' ? 267 : 285}"
              width="35" height="${shoes == 'Boots' ? 33 : 15}"
              rx="7" fill="$shoeColor"/>

        <!-- Arms -->
        <rect x="-${width + 21}" y="110"
              width="20" height="88" rx="10" fill="$skin"/>
        <rect x="${width + 1}" y="110"
              width="20" height="88" rx="10" fill="$skin"/>

        <!-- Neck -->
        <rect x="-12" y="79" width="24" height="30"
              rx="7" fill="$skin"/>

        <!-- Top -->
        <rect x="-$width" y="100" width="${width * 2}"
              height="91" rx="17" fill="$clothingColor"/>

        <!-- Sleeves -->
        <rect x="-${width + 23}" y="104" width="29"
              height="${top == 'T-shirt' ? 28 : 76}"
              rx="10" fill="$clothingColor"/>
        <rect x="${width - 6}" y="104" width="29"
              height="${top == 'T-shirt' ? 28 : 76}"
              rx="10" fill="$clothingColor"/>

        ${top == 'Hoodie' ? '''
        <path d="M -18 101 Q 0 132 18 101"
              fill="none" stroke="#FFFFFF" stroke-width="3"/>
        <rect x="-20" y="156" width="40" height="20"
              rx="6" fill="#000000" opacity="0.12"/>
        ''' : ''}

        ${top == 'Jacket' || top == 'Coat' ? '''
        <path d="M 0 100 L 0 190"
              stroke="#FFFFFF" stroke-width="2"/>
        <path d="M -25 148 L -12 148 M 12 148 L 25 148"
              stroke="#FFFFFF" stroke-width="2"/>
        ''' : ''}

        <!-- Ears and face -->
        <circle cx="-35" cy="54" r="8" fill="$skin"/>
        <circle cx="35" cy="54" r="8" fill="$skin"/>
        <ellipse cx="0" cy="50" rx="35" ry="43"
                 fill="$skin"/>

        <!-- Hair -->
        ${hair != 'Bald' ? '''
        <path d="M -35 45 Q -47 2 0 5
                 Q 47 2 35 45 Q 12 33 5 20
                 Q -15 38 -35 45 Z"
              fill="$hairColor"/>
        ''' : ''}

        ${hair == 'Curly' ? List.generate(7, (i) =>
          '<circle cx="${-30 + i * 10}" cy="17" r="13" fill="$hairColor"/>'
        ).join() : ''}

        ${hair == 'Bun' ? '''
        <circle cx="0" cy="0" r="19" fill="$hairColor"/>
        ''' : ''}

        ${hair == 'Ponytail' ? '''
        <ellipse cx="40" cy="57" rx="13" ry="36"
                 fill="$hairColor"/>
        ''' : ''}

        ${hair == 'Braids' ? List.generate(6, (i) =>
          '<circle cx="-34" cy="${65 + i * 11}" r="9" fill="$hairColor"/>'
          '<circle cx="34" cy="${65 + i * 11}" r="9" fill="$hairColor"/>'
        ).join() : ''}

        <!-- Eyebrows -->
        <path d="M -23 40 Q -15 35 -7 40
                 M 7 40 Q 15 35 23 40"
              stroke="$hairColor" stroke-width="2.5"
              fill="none"/>

        <!-- Eyes -->
        <ellipse cx="-14" cy="49" rx="7" ry="5" fill="white"/>
        <ellipse cx="14" cy="49" rx="7" ry="5" fill="white"/>
        <circle cx="-14" cy="49" r="3.5" fill="#30251F"/>
        <circle cx="14" cy="49" r="3.5" fill="#30251F"/>

        <!-- Nose -->
        <path d="M 0 53 L -3 63 L 3 63"
              stroke="#98694D" stroke-width="1.5"
              fill="none"/>

        <!-- Makeup -->
        ${makeup != 'None' ? '''
        <ellipse cx="-23" cy="65" rx="8" ry="4"
                 fill="#E87891" opacity="0.45"/>
        <ellipse cx="23" cy="65" rx="8" ry="4"
                 fill="#E87891" opacity="0.45"/>
        ''' : ''}

        ${makeup == 'Soft' || makeup == 'Bold' ? '''
        <path d="M -21 46 Q -14 39 -7 46
                 M 7 46 Q 14 39 21 46"
              stroke="${makeup == 'Bold' ? '#713F8F' : '#D89BA8'}"
              stroke-width="3" fill="none"/>
        ''' : ''}

        <!-- Lips -->
        <path d="M -10 72 Q 0 81 10 72"
              stroke="${makeup == 'Bold' ? '#B91C46' : makeup == 'Soft' ? '#DB6685' : '#A75E58'}"
              stroke-width="3" stroke-linecap="round"
              fill="none"/>

        <!-- Accessories -->
        ${accessory == 'Glasses' || accessory == 'Sunglasses' ? '''
        <rect x="-26" y="40" width="23" height="18"
              rx="6" stroke="#292524" stroke-width="3"
              fill="${accessory == 'Sunglasses' ? '#292524' : 'none'}"/>
        <rect x="3" y="40" width="23" height="18"
              rx="6" stroke="#292524" stroke-width="3"
              fill="${accessory == 'Sunglasses' ? '#292524' : 'none'}"/>
        <path d="M -3 47 L 3 47" stroke="#292524"
              stroke-width="3"/>
        ''' : ''}

        ${accessory == 'Hat' ? '''
        <rect x="-35" y="0" width="70" height="25"
              rx="12" fill="#374151"/>
        <rect x="-43" y="22" width="86" height="9"
              rx="4" fill="#374151"/>
        ''' : ''}

        ${accessory == 'Scarf' ? '''
        <rect x="-23" y="91" width="46" height="17"
              rx="7" fill="#DB6685"/>
        <rect x="9" y="104" width="15" height="48"
              rx="5" fill="#DB6685"/>
        ''' : ''}

        ${accessory == 'Earrings' ? '''
        <circle cx="-36" cy="65" r="5"
                stroke="#D4AF37" stroke-width="3" fill="none"/>
        <circle cx="36" cy="65" r="5"
                stroke="#D4AF37" stroke-width="3" fill="none"/>
        ''' : ''}
      </g>
    </svg>
    ''';

    return SvgPicture.string(
      svg,
      fit: BoxFit.contain,
    );
  }
}
