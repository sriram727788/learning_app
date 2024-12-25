// double centerX = size.width / 2;
// double centerY = size.height / 2;
// double letterHeight = size.height * 0.6;
// double letterWidth = letterHeight * 0.6; // Adjusted for better proportions

// final Map<String, List<List<Offset>>> letterStrokes = {
      // 'B': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 3, centerY - letterHeight / 2.5),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 4),
      //     Offset(centerX + letterWidth / 3, centerY),
      //     Offset(centerX - letterWidth / 2, centerY),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY),
      //     Offset(centerX + letterWidth / 3, centerY),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 4),
      //     Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.5),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      // ],
      // 'C': [
      //   [
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
      //     Offset(centerX + letterWidth / 3, centerY - letterHeight / 2.2),
      //     Offset(centerX, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 3, centerY - letterHeight / 3),
      //     Offset(centerX - letterWidth / 2, centerY),
      //     Offset(centerX - letterWidth / 3, centerY + letterHeight / 3),
      //     Offset(centerX, centerY + letterHeight / 2),
      //     Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.2),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 3),
      //   ],
      // ],
      // 'D': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 4, centerY - letterHeight / 2.2),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
      //     Offset(centerX + letterWidth * 0.6, centerY),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 3),
      //     Offset(centerX + letterWidth / 4, centerY + letterHeight / 2.2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      // ],
      // 'E': [
      //   [
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY),
      //     Offset(centerX + letterWidth / 3, centerY),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      // ],
      // 'F': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY),
      //     Offset(centerX + letterWidth / 3, centerY),
      //   ],
      // ],
      // 'G': [
      //   [
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
      //     Offset(centerX + letterWidth / 3, centerY - letterHeight / 2.2),
      //     Offset(centerX, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 3, centerY - letterHeight / 3),
      //     Offset(centerX - letterWidth / 2, centerY),
      //     Offset(centerX - letterWidth / 3, centerY + letterHeight / 3),
      //     Offset(centerX, centerY + letterHeight / 2),
      //     Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.2),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 3),
      //   ],
      //   [
      //     Offset(centerX + letterWidth / 2, centerY),
      //     Offset(centerX, centerY),
      //   ],
      // ],
      // 'H': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY),
      //     Offset(centerX + letterWidth / 2, centerY),
      //   ],
      // ],
      // 'I': [
      //   [
      //     Offset(centerX, centerY - letterHeight / 2),
      //     Offset(centerX, centerY + letterHeight / 2),
      //   ],
      // ],
      // 'J': [
      //   [
      //     Offset(centerX + letterWidth / 3, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 3, centerY + letterHeight / 4),
      //     Offset(centerX + letterWidth / 4, centerY + letterHeight / 2.5),
      //     Offset(centerX, centerY + letterHeight / 2),
      //     Offset(centerX - letterWidth / 4, centerY + letterHeight / 2.5),
      //     Offset(centerX - letterWidth / 3, centerY + letterHeight / 4),
      //   ],
      // ],
      // 'K': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      // ],
      // 'L': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      // ],
      // 'M': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX, centerY + letterHeight / 4),
      //   ],
      //   [
      //     Offset(centerX, centerY + letterHeight / 4),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      // ],
      // 'N': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //   ],
      // ],
      // 'O': [
      //   [
      //     Offset(centerX, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 3, centerY - letterHeight / 2.2),
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 3),
      //     Offset(centerX - letterWidth * 0.6, centerY),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 3),
      //     Offset(centerX - letterWidth / 3, centerY + letterHeight / 2.2),
      //     Offset(centerX, centerY + letterHeight / 2),
      //     Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.2),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 3),
      //     Offset(centerX + letterWidth * 0.6, centerY),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
      //     Offset(centerX + letterWidth / 3, centerY - letterHeight / 2.2),
      //     Offset(centerX, centerY - letterHeight / 2),
      //   ],
      // ],
      // 'P': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 3, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
      //     Offset(centerX + letterWidth / 3, centerY),
      //     Offset(centerX - letterWidth / 2, centerY),
      //   ],
      // ],
      // 'Q': [
      //   [
      //     Offset(centerX, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 3, centerY - letterHeight / 2.2),
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 3),
      //     Offset(centerX - letterWidth * 0.6, centerY),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 3),
      //     Offset(centerX - letterWidth / 3, centerY + letterHeight / 2.2),
      //     Offset(centerX, centerY + letterHeight / 2),
      //     Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.2),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 3),
      //     Offset(centerX + letterWidth * 0.6, centerY),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
      //     Offset(centerX + letterWidth / 3, centerY - letterHeight / 2.2),
      //     Offset(centerX, centerY - letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX, centerY + letterHeight / 6),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      // ],
      // 'R': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 3, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
      //     Offset(centerX + letterWidth / 3, centerY),
      //     Offset(centerX - letterWidth / 2, centerY),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      // ],
      // 'S': [
      //   [
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
      //     Offset(centerX + letterWidth / 3, centerY - letterHeight / 2.2),
      //     Offset(centerX, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 3, centerY - letterHeight / 2.2),
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 3),
      //     Offset(centerX - letterWidth / 3, centerY - letterHeight / 6),
      //     Offset(centerX, centerY),
      //     Offset(centerX + letterWidth / 3, centerY + letterHeight / 6),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 3),
      //     Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.2),
      //     Offset(centerX, centerY + letterHeight / 2),
      //     Offset(centerX - letterWidth / 3, centerY + letterHeight / 2.2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 3),
      //   ],
      // ],
      // 'T': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX, centerY - letterHeight / 2),
      //     Offset(centerX, centerY + letterHeight / 2),
      //   ],
      // ],
      // 'U': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 4),
      //     Offset(centerX - letterWidth / 3, centerY + letterHeight / 2.2),
      //     Offset(centerX, centerY + letterHeight / 2),
      //     Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.2),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 4),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //   ],
      // ],
      // 'V': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX, centerY + letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //   ],
      // ],
      // 'W': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 4, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 4, centerY + letterHeight / 2),
      //     Offset(centerX, centerY - letterHeight / 4),
      //   ],
      //   [
      //     Offset(centerX, centerY - letterHeight / 4),
      //     Offset(centerX + letterWidth / 4, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX + letterWidth / 4, centerY + letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //   ],
      // ],
      // 'X': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      // ],
      // 'Y': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX, centerY),
      //   ],
      //   [
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX, centerY),
      //   ],
      //   [
      //     Offset(centerX, centerY),
      //     Offset(centerX, centerY + letterHeight / 2),
      //   ],
      // ],
      // 'Z': [
      //   [
      //     Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      //   [
      //     Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
      //     Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
      //   ],
      // ],
      // };