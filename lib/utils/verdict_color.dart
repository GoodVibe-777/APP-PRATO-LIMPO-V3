import 'package:flutter/material.dart';

Color corParaVeredito(String veredito) {
  switch (veredito) {
    case 'bom':
      return Colors.green;
    case 'alerta':
      return Colors.red;
    default:
      return Colors.orange;
  }
}
