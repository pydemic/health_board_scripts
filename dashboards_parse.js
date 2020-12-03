const YAML = require('yamljs');
const fs = require('fs');

/* ###### SETTINGS ###### */
const inputFileName = 'dashboards.yml'
const outputFileName = 'dashboards.csv'
const outputFileNameDisabledFilters = 'dashboards_disabled_filters.csv'
const outputFileNameDashboardSections = 'dashboards_sections.csv'
/* ###### SETTINGS END ###### */

const data = YAML.load('./INPUT/'+inputFileName)

let output = ''
let outputDisabledFilters = ''
let outputDashboardSections = ''

Object.keys(data).forEach( item => {
  output = output + '\"' + item + '\"' + ','

  Object.keys(data[item]).forEach( (dataField, key) => {
    if(dataField !== 'disabled_filters' && dataField !== 'sections' ){
      output = output + '\"' + data[item][dataField] + '\"'
      if(dataField !== 'description'){
        output = output + ','
      }
    } else {
      if(dataField === 'disabled_filters') {
        data[item][dataField].forEach(disabledFilter => {
          outputDisabledFilters = outputDisabledFilters + 
          '\"' + item + '\"' + ',' + '\"' + disabledFilter + '\"' + '\n'
        })
      } else {
        data[item][dataField].forEach(section => {
          outputDashboardSections = outputDashboardSections + 
          '\"' + item + '\"' + ',' + '\"' + section  + '\"' + '\n'
        })
      }
    }
  })

  output = output + '\n'
});

fs.writeFile('./OUTPUT/'+outputFileName, output, function (err) {
    if (err) return console.log(err);
    console.log('file:'+outputFileName);
});

fs.writeFile('./OUTPUT/'+outputFileNameDisabledFilters, outputDisabledFilters, function (err) {
    if (err) return console.log(err);
    console.log('file:'+outputFileNameDisabledFilters);
});

fs.writeFile('./OUTPUT/'+outputFileNameDashboardSections, outputDashboardSections, function (err) {
    if (err) return console.log(err);
    console.log('file:'+outputFileNameDashboardSections);
});