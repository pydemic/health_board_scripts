const YAML = require('yamljs');
const fs = require('fs');

/* ###### SETTINGS ###### */
const inputFileName = 'indicators.yml'
const outputFileName = 'indicators.csv'
const outputFileNameSources = 'indicators_sources.csv'
const outputFileNameChildren = 'indicators_children.csv'

const indicatorsKeys = [
  'description', 
  'formula', 
  'measurement_unit',
  'reference',
  'reference',
  'sources',
  'children'
]
/* ###### SETTINGS END ###### */

const data = YAML.load('./INPUT/'+inputFileName)


let output = ''
let outputSources = ''
let outputChildren = ''

Object.keys(data).forEach( item => {

  let line = []
  line.push('\"' + item + '\"')

  indicatorsKeys.forEach( (dataField, key) => {
    if(data[item][dataField]){
      if(dataField !== 'sources' && dataField !== 'children' ){
        if(dataField !== 'measurement_unit' && data[item][dataField] !== '\%'){
          line.push( '\"' + data[item][dataField] + '\"')
        } else {
          line.push( '\"' + '%' + '\"')
        }
      } else {
        if(dataField === 'sources') {
          data[item][dataField].forEach(source => {
            outputSources = outputSources + 
            '\"' + item + '\"' + ',' + '\"' + source + '\"' + '\n'
          })
        } else {
          data[item][dataField].forEach(child => {
            outputChildren = outputChildren + 
            '\"' + item + '\"' + ',' + '\"' + child  + '\"' + '\n'
          })
        }
      }
    } else {
      line.push('')
    }
  })

  output = output + line.join(',') + '\n'
});

fs.writeFile('./OUTPUT/'+outputFileName, output, function (err) {
    if (err) return console.log(err);
    console.log('file:'+outputFileName);
});

fs.writeFile('./OUTPUT/'+outputFileNameSources, outputSources, function (err) {
    if (err) return console.log(err);
    console.log('file:'+outputFileNameSources);
});

fs.writeFile('./OUTPUT/'+outputFileNameChildren, outputChildren, function (err) {
    if (err) return console.log(err);
    console.log('file:'+outputFileNameChildren);
});