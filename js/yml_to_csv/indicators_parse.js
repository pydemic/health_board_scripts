const YAML = require('yamljs')
const fs = require('fs')
const { exec } = require('child_process')

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

const sort = (fileName) => {
  exec(`sort -o ./OUTPUT/${fileName} ./OUTPUT/${fileName}`, (err, stdout, stderr) => {
    if (err) {
      console.log(`error: ${err}`)
      return;
    }
    if (stdout) {
      console.log(`stdout: ${stdout}`)
    }
    if (stderr) {
      console.log(`stderr: ${stderr}`)
    }
  });
}

fs.writeFile('./OUTPUT/'+outputFileName, output, function (err) {
  if (err) return console.log(err)
  console.log('file:'+outputFileName)
  sort(outputFileName)
})


fs.writeFile('./OUTPUT/'+outputFileNameSources, outputSources, function (err) {
  if (err) return console.log(err)
  console.log('file:'+outputFileNameSources)
  sort(outputFileNameSources)
})


fs.writeFile('./OUTPUT/'+outputFileNameChildren, outputChildren, function (err) {
  if (err) return console.log(err)
  console.log('file:'+outputFileNameChildren)
  sort(outputFileNameChildren)
})
