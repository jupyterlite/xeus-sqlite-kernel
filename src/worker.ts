// Copyright (c) Thorsten Beier
// Copyright (c) JupyterLite Contributors
// Distributed under the terms of the Modified BSD License.

// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
import createXeusModule from './xeus_kernel.js';

// We alias self to ctx and give it our newly created type
const ctx: Worker = self as any;
let raw_xkernel: any;
let raw_xserver: any;

async function get_stdin() {
  const replyPromise = new Promise(resolve => {
    resolveInputReply = resolve;
  });
  return replyPromise;
}

// eslint-disable-next-line
// @ts-ignore: breaks typedoc
ctx.get_stdin = get_stdin;

// eslint-disable-next-line
// @ts-ignore: breaks typedoc
let resolveInputReply: any;

async function loadCppModule(moduleFactory: any): Promise<any> {
  const options: any = {};
  return moduleFactory(options).then((Module: any) => {
    raw_xkernel = new Module.xkernel();
    raw_xserver = raw_xkernel.get_server();
    raw_xkernel!.start();
  });
}

const loadCppModulePromise = loadCppModule(createXeusModule);

ctx.onmessage = async (event: MessageEvent): Promise<void> => {
  await loadCppModulePromise;

  const data = event.data;
  const msg = data.msg;
  const msg_type = msg.header.msg_type;

  if (msg_type === 'input_reply') {
    resolveInputReply(msg);
  } else {
    raw_xserver!.notify_listener(msg);
  }
};
