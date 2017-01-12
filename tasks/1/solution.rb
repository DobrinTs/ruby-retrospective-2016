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

CRITICAL_TEMPERATURES = {
  'water' => {melting_point: 0, boiling_point: 100},
  'ethanol' => {melting_point: -114, boiling_point: 78.37},
  'gold' => {melting_point: 1_064, boiling_point: 2_700},
  'silver' => {melting_point: 961.8, boiling_point: 2_162},
  'copper' => {melting_point: 1_085, boiling_point: 2_567}
}

def melting_point_of_substance(substance, units)
  convert_from_celsius(CRITICAL_TEMPERATURES[substance][:melting_point], units)
end

def boiling_point_of_substance(substance, units)
  convert_from_celsius(CRITICAL_TEMPERATURES[substance][:boiling_point], units)
end
