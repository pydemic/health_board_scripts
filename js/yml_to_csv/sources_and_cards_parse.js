const YAML = require('yamljs');
const fs = require('fs');

/* ###### SETTINGS ###### */
const inputFileName = 'cards.yml' // 'sources.yml'
const outputFileName = inputFileName.split('.')[0]+'.csv'
/* ###### SETTINGS END ###### */

const data = YAML.load('./INPUT/'+inputFileName)

let output = ''

Object.keys(data).forEach( item => {
  output = output + '\"' + item + '\"' + ','

  Object.keys(data[item]).forEach( (dataField, key) => {
    output = output + '\"' + data[item][dataField] + '\"'
    if(Object.keys(data[item]).length -1 !== key){
      output = output + ','
    }
  })

  output = output + '\n'
});

fs.writeFile('./OUTPUT/'+outputFileName, output, function (err) {
    if (err) return console.log(err);
    console.log('file:'+outputFileName);
});