def convert_to_celsius(degrees, from_units)
  if from_units == 'C'
    degrees
  elsif from_units == 'K'
    degrees - 273.15
  elsif from_units == 'F'
    (degrees - 32) * 5 / 9
  end
end

def convert_from_celsius(degrees, to_units)
  if to_units == 'C'
    degrees
  elsif to_units == 'K'
    degrees + 273.15
  elsif to_units == 'F'
    degrees * 1.8 + 32
  end
end

def convert_between_temperature_units(degrees, from_units, to_units)
  if to_units == from_units
    degrees
  else
    degrees_in_celsius = convert_to_celsius(degrees, from_units)
    convert_from_celsius(degrees_in_celsius, to_units)
  end
end

MELTING_POINTS = {
  'water' => 0, 'ethanol' => -114, 'gold' => 1_064,
  'silver' => 961.8, 'copper' => 1_085
}

def melting_point_of_substance(substance, in_which_temperature_unit)
  if MELTING_POINTS[substance]
    if in_which_temperature_unit == 'C'
      MELTING_POINTS[substance]
    elsif in_which_temperature_unit == 'K'
      convert_between_temperature_units(MELTING_POINTS[substance], 'C', 'K')
    elsif in_which_temperature_unit == 'F'
      convert_between_temperature_units(MELTING_POINTS[substance], 'C', 'F')
    end
  end
end

BOILING_POINTS = {
  'water' => 100, 'ethanol' => 78.37, 'gold' => 2_700,
  'silver' => 2_162, 'copper' => 2_567
}

def boiling_point_of_substance(substance, in_which_temperature_unit)
  if BOILING_POINTS[substance]
    if in_which_temperature_unit == 'C'
      BOILING_POINTS[substance]
    elsif in_which_temperature_unit == 'K'
      convert_between_temperature_units(BOILING_POINTS[substance], 'C', 'K')
    elsif in_which_temperature_unit == 'F'
      convert_between_temperature_units(BOILING_POINTS[substance], 'C', 'F')
    end
  end
end
