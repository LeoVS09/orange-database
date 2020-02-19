const fs = require('fs');
const path = require('path');

let read = new Promise((resolve, reject) => {
	fs.readFile(path.resolve(__dirname, '../.env-config'), 'utf8', (err, data)=> {
		if(err) {
			reject(err);
			return
		}

		resolve(data)
	})
});

read.then(data =>
	data.split('\n')
		.filter(row => row[0] === 'e')
		.map(row => row.slice(7))
		.join('\n')
)
	.then(data => {
		console.log('result data\n', data);
		return new Promise((resolve, reject) => {
			fs.writeFile(path.resolve(__dirname,'../.env-list'), data, 'utf8', err => {
				if(err){
					reject(err)
					return
				}

				resolve('File was write')
			})
		})
	})
	.then(text => console.log(text))
	.catch(error => {
		console.error(error)
	});
