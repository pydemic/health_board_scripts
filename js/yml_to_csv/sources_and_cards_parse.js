const YAML = require('yamljs')
const fs = require('fs')
const { exec } = require('child_process')

/* ###### SETTINGS ###### */
const inputFileName = 'cards.yml' // 'sources.yml'
const outputFileName = inputFileName.split('.')[0]+'.csv'
/* ###### SETTINGS END ###### */

const data = YAML.load('./INPUT/'+inputFileName)

let output = ''

Object.keys(data).forEach( item => {
  if(Object.keys(data[item]).some((item) => (item === 'indicator_id'))) {
    output = output + '\"' + data[item]['indicator_id'] + '\"' + ',' + '\"' + item + '\"' + ','
  } else {
    output = output + '\"' + item + '\"' + ','
  }

  Object.keys(data[item]).forEach( (dataField, key) => {
    if(dataField !== 'indicator_id') {
      output = output + '\"' + data[item][dataField] + '\"'
      if(Object.keys(data[item]).length -1 !== key){
        output = output + ','
      }
    }
  })

  output = output + '\n'
});

fs.writeFile('./OUTPUT/'+outputFileName, output, function (err) {
  if (err) return console.log(err)
  console.log('file:'+outputFileName)
  exec(`sort -o ./OUTPUT/${outputFileName} ./OUTPUT/${outputFileName}`, (err, stdout, stderr) => {
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

})

