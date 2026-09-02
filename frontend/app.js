/* =========================================================================
   STATE
   ========================================================================= */
let apiBase = document.getElementById('apiBaseInput').value.trim();
let currentView = 'assets';
let assetsCache = [];
let institutionsCache = [];
let overdueCache = [];
let openAssetTag = null;
let instFilter = '';
let siteFilter = '';

/* =========================================================================
   API LAYER — mirrors client/client.bal function-for-function
   ========================================================================= */
async function apiCall(path, options = {}) {
  const res = await fetch(apiBase + path, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  let body = null;
  try { body = await res.json(); } catch (_) { /* no body */ }
  if (!res.ok) {
    const message = (body && body.message) ? body.message : `Request failed (${res.status})`;
    throw new Error(message);
  }
  return body;
}

const api = {
  getAllAssets: () => apiCall('/assets'),
  createAsset: (asset) => apiCall('/assets', { method: 'POST', body: JSON.stringify(asset) }),
  getAsset: (tag) => apiCall(`/assets/${encodeURIComponent(tag)}`),
  updateAsset: (tag, asset) => apiCall(`/assets/${encodeURIComponent(tag)}`, { method: 'PUT', body: JSON.stringify(asset) }),
  deleteAsset: (tag) => apiCall(`/assets/${encodeURIComponent(tag)}`, { method: 'DELETE' }),
  getAssetsByInstitution: (inst) => apiCall(`/assets/institution/${encodeURIComponent(inst)}`),
  getAssetsByInstitutionAndSite: (inst, site) => apiCall(`/assets/institution/${encodeURIComponent(inst)}/site/${encodeURIComponent(site)}`),
  getOverdueAssets: () => apiCall('/assets/overdue'),
  listInstitutions: () => apiCall('/institutions'),
  addInstitution: (inst) => apiCall('/institutions', { method: 'POST', body: JSON.stringify(inst) }),
  removeInstitution: (id) => apiCall(`/institutions/${encodeURIComponent(id)}`, { method: 'DELETE' }),
  addComponent: (tag, comp) => apiCall(`/assets/${encodeURIComponent(tag)}/components`, { method: 'POST', body: JSON.stringify(comp) }),
  removeComponent: (tag, compId) => apiCall(`/assets/${encodeURIComponent(tag)}/components/${encodeURIComponent(compId)}`, { method: 'DELETE' }),
  addSchedule: (tag, sched) => apiCall(`/assets/${encodeURIComponent(tag)}/schedules`, { method: 'POST', body: JSON.stringify(sched) }),
  removeSchedule: (tag, id) => apiCall(`/assets/${encodeURIComponent(tag)}/schedules/${encodeURIComponent(id)}`, { method: 'DELETE' }),
  openWorkOrder: (tag, wo) => apiCall(`/assets/${encodeURIComponent(tag)}/workorders`, { method: 'POST', body: JSON.stringify(wo) }),
  updateWorkOrder: (tag, orderId, wo) => apiCall(`/assets/${encodeURIComponent(tag)}/workorders/${encodeURIComponent(orderId)}`, { method: 'PUT', body: JSON.stringify(wo) }),
  deleteWorkOrder: (tag, orderId) => apiCall(`/assets/${encodeURIComponent(tag)}/workorders/${encodeURIComponent(orderId)}`, { method: 'DELETE' }),
  addTask: (tag, orderId, task) => apiCall(`/assets/${encodeURIComponent(tag)}/workorders/${encodeURIComponent(orderId)}/tasks`, { method: 'POST', body: JSON.stringify(task) }),
};

/* =========================================================================
   TOASTS
   ========================================================================= */
function toast(message, isError = false) {
  const stack = document.getElementById('toastStack');
  const el = document.createElement('div');
  el.className = 'toast' + (isError ? ' error' : '');
  el.textContent = message;
  stack.appendChild(el);
  setTimeout(() => el.remove(), 4200);
}

/* =========================================================================
   CONNECTION CHECK
   ========================================================================= */
async function checkConnection() {
  const dot = document.getElementById('connDot');
  const label = document.getElementById('connLabel');
  try {
    await apiCall('/assets');
    dot.className = 'conn-dot up';
    label.textContent = 'Connected';
  } catch (e) {
    dot.className = 'conn-dot down';
    label.textContent = 'Not reachable';
  }
}

document.getElementById('apiBaseInput').addEventListener('change', (e) => {
  apiBase = e.target.value.trim().replace(/\/$/, '');
  checkConnection();
  refreshCurrentView();
});

/* =========================================================================
   NAV
   ========================================================================= */
document.querySelectorAll('.rail-link').forEach((btn) => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.rail-link').forEach((b) => b.classList.remove('active'));
    btn.classList.add('active');
    currentView = btn.dataset.view;
    renderView();
  });
});

function refreshCurrentView() { renderView(); }

/* =========================================================================
   VIEW ROUTER
   ========================================================================= */
async function renderView() {
  const main = document.getElementById('mainView');
  if (currentView === 'assets') return renderAssetsView(main);
  if (currentView === 'institutions') return renderInstitutionsView(main);
  if (currentView === 'overdue') return renderOverdueView(main);
}

/* =========================================================================
   ASSETS VIEW
   ========================================================================= */
async function renderAssetsView(main) {
  main.innerHTML = `
    <div class="view-header">
      <div>
        <h1>Assets</h1>
        <p>Every book, device, and space registered across every campus. Select a row for full detail.</p>
      </div>
      <button class="btn btn-primary" id="newAssetBtn">Add asset</button>
    </div>
    <div class="filter-bar">
      <div class="field">
        <label for="filterInst">Institution</label>
        <input id="filterInst" placeholder="e.g. NUST" value="${escapeAttr(instFilter)}" />
      </div>
      <div class="field">
        <label for="filterSite">Site / campus</label>
        <input id="filterSite" placeholder="Leave blank for all sites" value="${escapeAttr(siteFilter)}" />
      </div>
      <button class="btn btn-small" id="applyFilterBtn">Filter</button>
      <button class="btn btn-quiet btn-small" id="clearFilterBtn">Clear</button>
    </div>
    <div class="table-wrap"><table>
      <thead><tr><th>Tag</th><th>Name</th><th>Institution</th><th>Site</th><th>Status</th></tr></thead>
      <tbody id="assetsTbody"><tr class="empty-row"><td colspan="5">Loading…</td></tr></tbody>
    </table></div>
  `;

  document.getElementById('newAssetBtn').addEventListener('click', () => openModal('assetModal'));
  document.getElementById('applyFilterBtn').addEventListener('click', async () => {
    instFilter = document.getElementById('filterInst').value.trim();
    siteFilter = document.getElementById('filterSite').value.trim();
    await loadAssetsList();
  });
  document.getElementById('clearFilterBtn').addEventListener('click', async () => {
    instFilter = '';
    siteFilter = '';
    await renderAssetsView(main);
  });

  await loadAssetsList();
}

async function loadAssetsList() {
  const tbody = document.getElementById('assetsTbody');
  if (!tbody) return;
  tbody.innerHTML = `<tr class="empty-row"><td colspan="5">Loading…</td></tr>`;
  try {
    let list;
    if (instFilter && siteFilter) list = await api.getAssetsByInstitutionAndSite(instFilter, siteFilter);
    else if (instFilter) list = await api.getAssetsByInstitution(instFilter);
    else list = await api.getAllAssets();
    assetsCache = list;
    renderAssetsTable(list, tbody);
  } catch (e) {
    tbody.innerHTML = `<tr class="empty-row"><td colspan="5">Couldn't load assets — ${escapeHtml(e.message)}</td></tr>`;
    toast(`Couldn't load assets: ${e.message}`, true);
  }
}

function renderAssetsTable(list, tbody) {
  if (!list || list.length === 0) {
    tbody.innerHTML = `<tr class="empty-row"><td colspan="5">No assets match this view yet. Add one, or clear your filters.</td></tr>`;
    return;
  }
  tbody.innerHTML = list.map((a) => `
    <tr data-tag="${escapeAttr(a.assetTag)}">
      <td class="tag-cell">${escapeHtml(a.assetTag)}</td>
      <td>${escapeHtml(a.name)}</td>
      <td class="muted-cell">${escapeHtml(a.institution)}</td>
      <td class="muted-cell">${escapeHtml(a.site)}</td>
      <td><span class="badge badge-${a.status}">${formatStatus(a.status)}</span></td>
    </tr>
  `).join('');
  tbody.querySelectorAll('tr[data-tag]').forEach((row) => {
    row.addEventListener('click', () => openDrawer(row.dataset.tag));
  });
}

/* =========================================================================
   OVERDUE VIEW
   ========================================================================= */
async function renderOverdueView(main) {
  main.innerHTML = `
    <div class="view-header">
      <div>
        <h1>Overdue</h1>
        <p>Assets carrying at least one maintenance, servicing, or booking schedule whose due date has passed.</p>
      </div>
    </div>
    <div class="table-wrap"><table>
      <thead><tr><th>Tag</th><th>Name</th><th>Institution</th><th>Overdue schedule</th></tr></thead>
      <tbody id="overdueTbody"><tr class="empty-row"><td colspan="4">Loading…</td></tr></tbody>
    </table></div>
  `;
  const tbody = document.getElementById('overdueTbody');
  try {
    const list = await api.getOverdueAssets();
    overdueCache = list;
    if (!list || list.length === 0) {
      tbody.innerHTML = `<tr class="empty-row"><td colspan="4">Nothing overdue right now. Every schedule is on track.</td></tr>`;
      return;
    }
    tbody.innerHTML = list.map((a) => {
      const overdueScheds = (a.schedules || []).map((s) => `${escapeHtml(s.type)} · due ${escapeHtml(s.dueDate)}`).join('<br/>');
      return `
        <tr data-tag="${escapeAttr(a.assetTag)}">
          <td class="tag-cell">${escapeHtml(a.assetTag)}</td>
          <td>${escapeHtml(a.name)}</td>
          <td class="muted-cell">${escapeHtml(a.institution)}</td>
          <td class="muted-cell">${overdueScheds || '—'}</td>
        </tr>`;
    }).join('');
    tbody.querySelectorAll('tr[data-tag]').forEach((row) => {
      row.addEventListener('click', () => openDrawer(row.dataset.tag));
    });
  } catch (e) {
    tbody.innerHTML = `<tr class="empty-row"><td colspan="4">Couldn't load the overdue list — ${escapeHtml(e.message)}</td></tr>`;
  }
}

/* =========================================================================
   INSTITUTIONS VIEW
   ========================================================================= */
async function renderInstitutionsView(main) {
  main.innerHTML = `
    <div class="view-header">
      <div>
        <h1>Institutions</h1>
        <p>Every registered institution allowed to hold assets in the ledger.</p>
      </div>
      <button class="btn btn-primary" id="newInstBtn">Add institution</button>
    </div>
    <div class="table-wrap"><table>
      <thead><tr><th>Institution ID</th><th>Name</th><th>Sites</th><th></th></tr></thead>
      <tbody id="instTbody"><tr class="empty-row"><td colspan="4">Loading…</td></tr></tbody>
    </table></div>
  `;
  document.getElementById('newInstBtn').addEventListener('click', () => openModal('instModal'));
  await loadInstitutions();
}

async function loadInstitutions() {
  const tbody = document.getElementById('instTbody');
  if (!tbody) return;
  try {
    const list = await api.listInstitutions();
    institutionsCache = list;
    if (!list || list.length === 0) {
      tbody.innerHTML = `<tr class="empty-row"><td colspan="4">No institutions registered yet.</td></tr>`;
      return;
    }
    tbody.innerHTML = list.map((i) => `
      <tr>
        <td class="tag-cell">${escapeHtml(i.institutionId)}</td>
        <td>${escapeHtml(i.name)}</td>
        <td class="muted-cell">${(i.sites || []).map(escapeHtml).join(', ') || '—'}</td>
        <td><button class="btn btn-quiet btn-small remove-inst" data-id="${escapeAttr(i.institutionId)}">Remove</button></td>
      </tr>
    `).join('');
    tbody.querySelectorAll('.remove-inst').forEach((btn) => {
      btn.addEventListener('click', async (ev) => {
        ev.stopPropagation();
        try {
          await api.removeInstitution(btn.dataset.id);
          toast('Institution removed.');
          await loadInstitutions();
        } catch (e) {
          toast(`Couldn't remove institution: ${e.message}`, true);
        }
      });
    });
  } catch (e) {
    tbody.innerHTML = `<tr class="empty-row"><td colspan="4">Couldn't load institutions — ${escapeHtml(e.message)}</td></tr>`;
  }
}

/* =========================================================================
   NEW ASSET MODAL
   ========================================================================= */
document.getElementById('assetForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const newAsset = {
    assetTag: val('f-tag'),
    name: val('f-name'),
    institution: val('f-institution'),
    site: val('f-site'),
    dateAcquired: val('f-date'),
  };
  const desc = val('f-description');
  if (desc) newAsset.description = desc;
  try {
    await api.createAsset(newAsset);
    toast(`Added ${newAsset.assetTag}.`);
    closeModal('assetModal');
    document.getElementById('assetForm').reset();
    if (currentView === 'assets') await loadAssetsList();
  } catch (e) {
    toast(`Couldn't add asset: ${e.message}`, true);
  }
});
document.getElementById('assetModalCancel').addEventListener('click', () => closeModal('assetModal'));

document.getElementById('instForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  const sitesRaw = val('i-sites');
  const newInst = {
    institutionId: val('i-id'),
    name: val('i-name'),
    sites: sitesRaw ? sitesRaw.split(',').map((s) => s.trim()).filter(Boolean) : [],
  };
  try {
    await api.addInstitution(newInst);
    toast(`Added ${newInst.institutionId}.`);
    closeModal('instModal');
    document.getElementById('instForm').reset();
    await loadInstitutions();
  } catch (e) {
    toast(`Couldn't add institution: ${e.message}`, true);
  }
});
document.getElementById('instModalCancel').addEventListener('click', () => closeModal('instModal'));

function val(id) { return document.getElementById(id).value.trim(); }
function openModal(id) { document.getElementById(id).classList.add('show'); }
function closeModal(id) { document.getElementById(id).classList.remove('show'); }

/* =========================================================================
   DETAIL DRAWER
   ========================================================================= */
async function openDrawer(tag) {
  openAssetTag = tag;
  const drawer = document.getElementById('assetDrawer');
  const scrim = document.getElementById('scrim');
  drawer.innerHTML = `<div class="drawer-body" style="padding-top:24px;">Loading ${escapeHtml(tag)}…</div>`;
  drawer.classList.add('show');
  scrim.classList.add('show');
  await loadDrawerContent(tag);
}

function closeDrawer() {
  document.getElementById('assetDrawer').classList.remove('show');
  document.getElementById('scrim').classList.remove('show');
  openAssetTag = null;
}
document.getElementById('scrim').addEventListener('click', closeDrawer);

async function loadDrawerContent(tag) {
  const drawer = document.getElementById('assetDrawer');
  try {
    const a = await api.getAsset(tag);
    drawer.innerHTML = buildDrawerHtml(a);
    wireDrawerEvents(a);
  } catch (e) {
    drawer.innerHTML = `<div class="drawer-body" style="padding-top:24px;">Couldn't load this asset — ${escapeHtml(e.message)}</div>`;
  }
}

function buildDrawerHtml(a) {
  const components = (a.components || []).map((c) => `
    <div class="mini-item">
      <div class="mini-item-top">
        <div><div class="mini-item-title">${escapeHtml(c.name)}</div>
        <div class="mini-item-sub">${escapeHtml(c.compId)}${c.description ? ' · ' + escapeHtml(c.description) : ''}</div></div>
        <button class="btn btn-quiet btn-small remove-comp" data-comp="${escapeAttr(c.compId)}">Remove</button>
      </div>
    </div>`).join('') || `<div class="mini-empty">No components recorded.</div>`;

  const schedules = (a.schedules || []).map((s) => `
    <div class="mini-item">
      <div class="mini-item-top">
        <div><div class="mini-item-title">${escapeHtml(s.type)} — due ${escapeHtml(s.dueDate)}</div>
        <div class="mini-item-sub">${escapeHtml(s.scheduleId)}${s.description ? ' · ' + escapeHtml(s.description) : ''}</div></div>
        <button class="btn btn-quiet btn-small remove-sched" data-sched="${escapeAttr(s.scheduleId)}">Remove</button>
      </div>
    </div>`).join('') || `<div class="mini-empty">No schedules recorded.</div>`;

  const workOrders = (a.workOrders || []).map((wo) => {
    const tasks = (wo.tasks || []).map((t) => `
      <li class="task-item ${t.completed ? 'done' : ''}"><span>${escapeHtml(t.description)}</span><span>${t.completed ? 'done' : 'open'}</span></li>
    `).join('') || `<li class="task-item">No sub-tasks yet.</li>`;
    return `
      <div class="mini-item">
        <div class="mini-item-top">
          <div><div class="mini-item-title">${escapeHtml(wo.description)}</div>
          <div class="mini-item-sub">${escapeHtml(wo.orderId)} · ${escapeHtml(wo.status)}</div></div>
          <button class="btn btn-quiet btn-small remove-wo" data-wo="${escapeAttr(wo.orderId)}">Remove</button>
        </div>
        <ul class="task-list">${tasks}</ul>
        <div class="wo-status-row">
          <select class="wo-status-select" data-wo="${escapeAttr(wo.orderId)}">
            <option value="OPEN" ${wo.status === 'OPEN' ? 'selected' : ''}>OPEN</option>
            <option value="IN_PROGRESS" ${wo.status === 'IN_PROGRESS' ? 'selected' : ''}>IN_PROGRESS</option>
            <option value="CLOSED" ${wo.status === 'CLOSED' ? 'selected' : ''}>CLOSED</option>
          </select>
          <button class="btn btn-small update-wo-status" data-wo="${escapeAttr(wo.orderId)}">Update status</button>
        </div>
        <div class="inline-form" style="margin-top:10px;">
          <div class="field"><input type="text" class="new-task-desc" data-wo="${escapeAttr(wo.orderId)}" placeholder="New sub-task description" /></div>
          <button class="btn btn-small add-task-btn" data-wo="${escapeAttr(wo.orderId)}">Add task</button>
        </div>
      </div>`;
  }).join('') || `<div class="mini-empty">No work orders open.</div>`;

  return `
    <div class="drawer-head">
      <div class="drawer-head-top">
        <div>
          <div class="drawer-tag">${escapeHtml(a.assetTag)}</div>
          <div class="drawer-name">${escapeHtml(a.name)}</div>
        </div>
        <button class="btn btn-quiet" id="closeDrawerBtn">Close</button>
      </div>
      <div class="drawer-meta">${escapeHtml(a.institution)} — ${escapeHtml(a.site)} · acquired ${escapeHtml(a.dateAcquired)}</div>
      <div style="margin-top:10px;"><span class="badge badge-${a.status}">${formatStatus(a.status)}</span></div>
      <div class="drawer-actions">
        <select id="statusSelect">
          <option value="AVAILABLE" ${a.status === 'AVAILABLE' ? 'selected' : ''}>AVAILABLE</option>
          <option value="LOANED_OUT" ${a.status === 'LOANED_OUT' ? 'selected' : ''}>LOANED_OUT</option>
          <option value="OCCUPIED" ${a.status === 'OCCUPIED' ? 'selected' : ''}>OCCUPIED</option>
          <option value="UNDER_MAINTENANCE" ${a.status === 'UNDER_MAINTENANCE' ? 'selected' : ''}>UNDER_MAINTENANCE</option>
          <option value="DISPOSED" ${a.status === 'DISPOSED' ? 'selected' : ''}>DISPOSED</option>
        </select>
        <button class="btn btn-small" id="saveStatusBtn">Save status</button>
        <button class="btn btn-danger btn-small" id="deleteAssetBtn">Delete asset</button>
      </div>
    </div>
    <div class="drawer-body">
      <div class="drawer-section">
        <h3>Components</h3>
        <div class="mini-list">${components}</div>
        <div class="inline-form">
          <div class="field"><input type="text" id="newCompName" placeholder="Component name" /></div>
          <div class="field"><input type="text" id="newCompDesc" placeholder="Description (optional)" /></div>
          <button class="btn btn-small" id="addCompBtn">Add component</button>
        </div>
      </div>
      <div class="drawer-section">
        <h3>Schedules</h3>
        <div class="mini-list">${schedules}</div>
        <div class="inline-form">
          <div class="field">
            <select id="newSchedType">
              <option value="MAINTENANCE">MAINTENANCE</option>
              <option value="BOOKING">BOOKING</option>
              <option value="SERVICING">SERVICING</option>
            </select>
          </div>
          <div class="field"><input type="date" id="newSchedDue" /></div>
          <div class="field"><input type="text" id="newSchedDesc" placeholder="Description (optional)" /></div>
          <button class="btn btn-small" id="addSchedBtn">Add schedule</button>
        </div>
      </div>
      <div class="drawer-section">
        <h3>Work orders</h3>
        <div class="mini-list">${workOrders}</div>
        <div class="inline-form">
          <div class="field"><input type="text" id="newWoDesc" placeholder="Fault or work order description" /></div>
          <button class="btn btn-small" id="addWoBtn">Open work order</button>
        </div>
      </div>
    </div>
  `;
}

function wireDrawerEvents(a) {
  const tag = a.assetTag;
  const drawer = document.getElementById('assetDrawer');

  drawer.querySelector('#closeDrawerBtn').addEventListener('click', closeDrawer);

  drawer.querySelector('#saveStatusBtn').addEventListener('click', async () => {
    const newStatus = drawer.querySelector('#statusSelect').value;
    try {
      const updated = { ...a, status: newStatus };
      await api.updateAsset(tag, updated);
      toast(`Status updated to ${formatStatus(newStatus)}.`);
      await loadDrawerContent(tag);
      if (currentView === 'assets') await loadAssetsList();
    } catch (e) { toast(`Couldn't update status: ${e.message}`, true); }
  });

  drawer.querySelector('#deleteAssetBtn').addEventListener('click', async () => {
    if (!confirm(`Delete ${tag}? This can't be undone.`)) return;
    try {
      await api.deleteAsset(tag);
      toast(`${tag} deleted.`);
      closeDrawer();
      if (currentView === 'assets') await loadAssetsList();
      if (currentView === 'overdue') await renderOverdueView(document.getElementById('mainView'));
    } catch (e) { toast(`Couldn't delete asset: ${e.message}`, true); }
  });

  drawer.querySelectorAll('.remove-comp').forEach((btn) => {
    btn.addEventListener('click', async () => {
      try { await api.removeComponent(tag, btn.dataset.comp); toast('Component removed.'); await loadDrawerContent(tag); }
      catch (e) { toast(`Couldn't remove component: ${e.message}`, true); }
    });
  });

  drawer.querySelector('#addCompBtn').addEventListener('click', async () => {
    const name = drawer.querySelector('#newCompName').value.trim();
    const description = drawer.querySelector('#newCompDesc').value.trim();
    if (!name) { toast('Component needs a name.', true); return; }
    const comp = { compId: '', name };
    if (description) comp.description = description;
    try { await api.addComponent(tag, comp); toast('Component added.'); await loadDrawerContent(tag); }
    catch (e) { toast(`Couldn't add component: ${e.message}`, true); }
  });

  drawer.querySelectorAll('.remove-sched').forEach((btn) => {
    btn.addEventListener('click', async () => {
      try { await api.removeSchedule(tag, btn.dataset.sched); toast('Schedule removed.'); await loadDrawerContent(tag);
        if (currentView === 'overdue') await renderOverdueView(document.getElementById('mainView')); }
      catch (e) { toast(`Couldn't remove schedule: ${e.message}`, true); }
    });
  });

  drawer.querySelector('#addSchedBtn').addEventListener('click', async () => {
    const type = drawer.querySelector('#newSchedType').value;
    const dueDate = drawer.querySelector('#newSchedDue').value;
    const description = drawer.querySelector('#newSchedDesc').value.trim();
    if (!dueDate) { toast('Pick a due date for the schedule.', true); return; }
    const sched = { scheduleId: '', type, dueDate };
    if (description) sched.description = description;
    try { await api.addSchedule(tag, sched); toast('Schedule added.'); await loadDrawerContent(tag); }
    catch (e) { toast(`Couldn't add schedule: ${e.message}`, true); }
  });

  drawer.querySelectorAll('.remove-wo').forEach((btn) => {
    btn.addEventListener('click', async () => {
      try { await api.deleteWorkOrder(tag, btn.dataset.wo); toast('Work order removed.'); await loadDrawerContent(tag); }
      catch (e) { toast(`Couldn't remove work order: ${e.message}`, true); }
    });
  });

  drawer.querySelectorAll('.update-wo-status').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const orderId = btn.dataset.wo;
      const select = drawer.querySelector(`.wo-status-select[data-wo="${cssEscape(orderId)}"]`);
      const wo = (a.workOrders || []).find((w) => w.orderId === orderId);
      try {
        await api.updateWorkOrder(tag, orderId, { orderId, status: select.value, description: wo ? wo.description : '' });
        toast('Work order status updated.');
        await loadDrawerContent(tag);
      } catch (e) { toast(`Couldn't update work order: ${e.message}`, true); }
    });
  });

  drawer.querySelectorAll('.add-task-btn').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const orderId = btn.dataset.wo;
      const input = drawer.querySelector(`.new-task-desc[data-wo="${cssEscape(orderId)}"]`);
      const description = input.value.trim();
      if (!description) { toast('Describe the sub-task first.', true); return; }
      try {
        await api.addTask(tag, orderId, { taskId: '', description });
        toast('Task added.');
        await loadDrawerContent(tag);
      } catch (e) { toast(`Couldn't add task: ${e.message}`, true); }
    });
  });

  drawer.querySelector('#addWoBtn').addEventListener('click', async () => {
    const description = drawer.querySelector('#newWoDesc').value.trim();
    if (!description) { toast('Describe the fault or work order first.', true); return; }
    try {
      await api.openWorkOrder(tag, { orderId: '', status: '', description });
      toast('Work order opened.');
      await loadDrawerContent(tag);
    } catch (e) { toast(`Couldn't open work order: ${e.message}`, true); }
  });
}

/* =========================================================================
   HELPERS
   ========================================================================= */
function formatStatus(status) {
  return (status || '').toLowerCase().replace(/_/g, ' ');
}
function escapeHtml(str) {
  return String(str ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}
function escapeAttr(str) { return escapeHtml(str); }
function cssEscape(str) { return String(str).replace(/["\\]/g, '\\$&'); }

/* =========================================================================
   INIT
   ========================================================================= */
checkConnection();
renderView();
setInterval(checkConnection, 15000);