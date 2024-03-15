
var subnet1 = null == null ? [] : [{
  name: 1
  properties: {
    addressPrefix: null
  }
}]

var subnet2 = 1 == null ? [] : [{
  name: 2
  properties: {
    addressPrefix: 'anything'
  }
}]

var subnet3 = 1 == null ? [] : [{
  name: 3
  properties: {
    addressPrefix: 'anything'
  }
}]

var subnets = concat(subnet1, subnet2, subnet3)


output subnets array = subnets
