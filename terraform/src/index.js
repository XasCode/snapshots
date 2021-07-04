const {Resource} = require('@google-cloud/resource');
const { Storage } = require('@google-cloud/storage');
const Compute = require('@google-cloud/compute');
const {google} = require('googleapis');    
const { SecretManagerServiceClient } = require('@google-cloud/secret-manager');

/**
 * Triggered from a message on a Cloud Pub/Sub topic.
 *
 * @param {!Object} event Event payload.
 * @param {!Object} context Metadata for the event.
 */
exports.helloPubSub = async (event, _context) => {
  const message = event.data
    ? Buffer.from(event.data, 'base64').toString()
    : `Inventory disks, check for backup schedules, and create a default schedule if required.`;
  console.log(message);
  
  async function getProjectId() {
    const compute = new Compute();
    const thisPrj = compute.project();
    const prjData = await thisPrj.get();
    console.log(`${JSON.stringify(prjData[0].metadata)}`);
    const prj = prjData[0].metadata.name;
    console.log(`${JSON.stringify(prj)}`);
    return prj;
  }

  // Our inventory object
  function ProjectDiskInventory() {
    return {
      inventory: {},
      // Add disks to inventory
      addDisks: function (disks) {
        disks.forEach(disk => {
          this.inventory[disk.metadata.selfLink] = {
            disk: disk.name,
            diskZone: disk.zone.name,
            policies: disk.metadata.resourcePolicies !== undefined
              ? disk.metadata.resourcePolicies.map(curr => (curr.slice(-25)))
              : [],
            snapshots: [],
          };
        });
        return this;
      },
      // Get list of snapshots and add to inventory matching on disk id
      addSnapshots: function(snapshots) {
        snapshots.forEach(snapshot => {
          this.inventory[snapshot.metadata.sourceDisk] = this.inventory[snapshot.metadata.sourceDisk]
            ? this.inventory[snapshot.metadata.sourceDisk] 
            : {snapshots: []};
          this.inventory[snapshot.metadata.sourceDisk].snapshots.push(snapshot.name.slice(-10));
        });
        return this;
      },
      // Get list of VMs and add to inventory matching on disk id
      addVms: function(vms) {
        vms.forEach(vm => {
          const disks = vm.metadata.disks;
          disks.forEach(disk => {
            this.inventory[disk.source] = this.inventory[disk.source]
              ? this.inventory[disk.source]
              : {policies: [], snapshots: []};
            this.inventory[disk.source].vm = vm.name; 
          });
        });
        return this;
      },
      // Print contents
      debug: function() {
        Object.keys(this.inventory).map(key => {
          console.log(`${key}: ${this.inventory[key]}`);
        });
        return this;
      }
    };
  }

  // Add disk details to inventory for each project
  async function getProjectDiskInventoryDetails(projectId) {
    const compute = new Compute({projectId: projectId});

    const disks = (await compute.getDisks())[0];
    const snapshots = (await compute.getSnapshots())[0];
    const vms = (await compute.getVMs())[0];

    const project_disk_inventory = new ProjectDiskInventory();
    return project_disk_inventory.addDisks(disks).addSnapshots(snapshots).addVms(vms).inventory;
  }

  // Convert our project disk inventory from map to list, and add project field
  async function getActiveProjectDiskInventoryDetails(project) {  
    if (project.metadata.lifecycleState == 'ACTIVE') {
      const d = await getProjectDiskInventoryDetails(project.id);
      return Object.keys(d).map(curr => ({
        project: project.id,
        id: curr.slice(-40), 
        disk: d[curr].disk, 
        diskZone: d[curr].diskZone, 
        policies: d[curr]['policies'] ? d[curr]['policies'] : [], 
        snapshots: d[curr]['snapshots'] ? d[curr]['snapshots'] : [], 
        vm: d[curr].vm
      }));
    }
    return [];
  }

  // Get list of all projects - note: must have access
  async function getProjects() {
    const resource = new Resource();
    const [projects] = await resource.getProjects();
    return projects;
  }

  // Consolidate inventories from each project into one list
  // return both the full list and a list of disks missing a backup policy
  async function getAllActiveProjectDiskInventoryDetails() {
    const disk_inventory_details = [];
    const projects = await getProjects();
    
    for (let count=0; count < projects.length; count++) {
      disk_inventory_details.push(...(await getActiveProjectDiskInventoryDetails(projects[count])));
    }

    return {
      disk_inventory_details,
      disks_missing_policies: disk_inventory_details.filter(curr => (!curr.policies.length)),
      disks_with_shorter_default_policies: disk_inventory_details.filter(curr => (curr.policies.length)),
    };
  }

  // Generate a timestamp
  function getTimeStamp() {
    const moment = require('moment');
    const format = "YYYYMMDD-HHmmss"
    const date = Date.now();
    return moment(date).format(format);
  }

  // Generate the filename from the timestamp
  function getObjectFilename() {
    const filename = `${getTimeStamp()}.json`;
    return filename;
  }

  // Save some JSON (our disk inventory) to the specified filename
  async function savDiskInventoryToObject(diskInventory, filename) {
    const storage = new Storage();
    const project_id = await getProjectId();
    const bucketname = `backup_records_${project_id}`;
    const myBucket = storage.bucket(bucketname);
    const file = myBucket.file(filename);
    await file.save(JSON.stringify(diskInventory, undefined, 2));  
  }

  // Save our disk inventory
  async function saveDiskInventoryToTimestampFilenameObject(disk_inventory_details) {
    const filename = getObjectFilename();
    await savDiskInventoryToObject(disk_inventory_details, filename);
    return filename;
  }

  // create an html table from a list of disks
  function createTable(disk_list) {
    return `
      <table style="border: 1px solid black; border-spacing: 0; border-collapse: collapse;">
        <tr>
          <th style="border: 1px solid black; border-spacing: 0;">(index)</th>
          <th style="border: 1px solid black; border-spacing: 0;">project</th>
          <th style="border: 1px solid black; border-spacing: 0;">id</th>
          <th style="border: 1px solid black; border-spacing: 0;">disk</th>
          <th style="border: 1px solid black; border-spacing: 0;">policies</th>
          <th style="border: 1px solid black; border-spacing: 0;">snapshots</th>
          <th style="border: 1px solid black; border-spacing: 0;">vm</th>
        </tr>${disk_list.map( (row, i) => (`
        <tr>
          <td style="border: 1px solid black; border-spacing: 0;">${i}</td>
          <td style="border: 1px solid black; border-spacing: 0;">${row.project}</td>
          <td style="border: 1px solid black; border-spacing: 0;">${row.id}</td>
          <td style="border: 1px solid black; border-spacing: 0;">${row.disk}</td>
          <td style="border: 1px solid black; border-spacing: 0;">${JSON.stringify(row.policies)}</td>
          <td style="border: 1px solid black; border-spacing: 0;">${JSON.stringify(row.snapshots)}</td>
          <td style="border: 1px solid black; border-spacing: 0;">${row.vm}</td>
        </tr>`)).join('')}
      </table>
    `;
  }

  // object and functions to create HTML output for email
  const html = {
    content: [],
    // add some text inside <p> tags </p>
    addParagraph: function(para) {
      this.content.push(`<p>${para}</p>`);
      return this;
    },
    // create an html table from list of disk details
    addTable: function(inventory_details) {
      this.content.push(createTable(inventory_details));
      return this;
    },
    // create an unordered list
    addUnorderedList: function(list) {
      this.content.push(`
        <ul>
        ${list.map(curr => (`
          <li>${JSON.stringify(curr)}</li>
        `))}
        </ul>
      `);
      return this;
    },
    // join list of html elements into a string
    join: function(token) {
      return this.content.join(token);
    }
  };

  async function getApiKey() {
    const secretManagerServiceClient = new SecretManagerServiceClient();
    const project_id = await getProjectId();
    const name = `projects/${project_id}/secrets/SENDGRID_API_KEY/versions/latest`;
    const [version] = await secretManagerServiceClient.accessSecretVersion({ name });
    return version.payload.data.toString();
  };
      
// Send email
  async function sendEmail(html_content) {
    const sgMail = require('@sendgrid/mail');
    
    if (true) {
      try {
        const msg = {
          to: 'justin@staubach.us',
          from: 'contact@jsdevtools.com',
          subject: 'Missing Backups',
          html: html_content 
        };
        const sendgrid_api_key = await getApiKey();
        await sgMail.setApiKey(sendgrid_api_key);
        await sgMail.send(msg);
        console.log('Email sent');
      } catch (error) {
        console.error(error)
      }
    } else {
      console.log(`No disks missing backups. Skipping email notification.`);
    }
  }

  /*********
   * Start *
   *********/

  const {disk_inventory_details, disks_missing_policies} = await getAllActiveProjectDiskInventoryDetails();

  const filename = await saveDiskInventoryToTimestampFilenameObject(disk_inventory_details);

  const html_content = html
    .addParagraph(`Saved full disk inventory to: ${filename}`)
    .addParagraph(`Disks missing backups:`)
    .addTable(disks_missing_policies)
    .addParagraph(`All disks:`)
    .addTable(disk_inventory_details)
    .join('');

  await sendEmail(html_content);
};
